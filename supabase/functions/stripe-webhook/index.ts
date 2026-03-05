// Supabase Edge Function: stripe-webhook
// ─────────────────────────────────────────────────────────────────────────────
// Listens for Stripe webhook events and marks users as paid in the DB.
//
// Required environment variables:
//   STRIPE_SECRET_KEY         — your Stripe secret key
//   STRIPE_WEBHOOK_SECRET     — from Stripe Dashboard → Webhooks → Signing secret
//                               (whsec_...)
//
// Stripe webhook events handled:
//   checkout.session.completed  — one-time payment succeeded
//   payment_intent.succeeded    — backup event for direct payment intents
//
// Database requirement:
//   Table: public.user_licences
//   Columns:
//     user_id      uuid  PRIMARY KEY  REFERENCES auth.users(id)
//     is_paid      boolean DEFAULT false
//     paid_at      timestamptz
//     stripe_session_id  text
//
//   RLS policy: service_role can insert/update (function uses service role key).
//
// Deploy with:
//   supabase functions deploy stripe-webhook --no-verify-jwt
// ─────────────────────────────────────────────────────────────────────────────

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
});

// Use the service role key so we can write to user_licences regardless of RLS.
const supabase = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
);

serve(async (req: Request) => {
  const sig   = req.headers.get("stripe-signature") ?? "";
  const secret = Deno.env.get("STRIPE_WEBHOOK_SECRET") ?? "";
  const body  = await req.text();

  let event: Stripe.Event;

  try {
    event = await stripe.webhooks.constructEventAsync(body, sig, secret);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("[stripe-webhook] Signature verification failed:", msg);
    return new Response(`Webhook Error: ${msg}`, { status: 400 });
  }

  // ── Handle events ──────────────────────────────────────────────────────────

  if (
    event.type === "checkout.session.completed" ||
    event.type === "payment_intent.succeeded"
  ) {
    const session = event.data.object as Stripe.Checkout.Session;
    const userId  = session.metadata?.user_id ?? session.client_reference_id;

    if (!userId) {
      console.error("[stripe-webhook] No user_id in session metadata", session.id);
      // Return 200 so Stripe doesn't retry — this is a data issue, not transient.
      return new Response("ok — no user_id", { status: 200 });
    }

    const { error } = await supabase
      .from("user_licences")
      .upsert(
        {
          user_id:           userId,
          is_paid:           true,
          paid_at:           new Date().toISOString(),
          stripe_session_id: session.id,
        },
        { onConflict: "user_id" },
      );

    if (error) {
      console.error("[stripe-webhook] DB upsert failed:", error.message);
      // Return 500 so Stripe retries the webhook.
      return new Response("DB error", { status: 500 });
    }

    console.log(`[stripe-webhook] Marked user ${userId} as paid (session ${session.id})`);
  } else {
    // Log unhandled events for debugging but always return 200.
    console.log(`[stripe-webhook] Unhandled event type: ${event.type}`);
  }

  return new Response("ok", { status: 200 });
});
