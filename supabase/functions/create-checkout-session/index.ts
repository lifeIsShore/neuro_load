// Supabase Edge Function: create-checkout-session
// ─────────────────────────────────────────────────────────────────────────────
// Creates a Stripe Checkout Session for the NeuroLoad lifetime licence (€49).
//
// Required environment variables (set in Supabase Dashboard → Edge Functions → Secrets):
//   STRIPE_SECRET_KEY        — your Stripe secret key (sk_live_... or sk_test_...)
//   STRIPE_PRICE_ID          — the Stripe Price ID for the €49 lifetime product
//   APP_SUCCESS_URL          — deep-link or universal link on payment success
//                              e.g. "neuroload://payment/success"
//   APP_CANCEL_URL           — deep-link or universal link on cancellation
//                              e.g. "neuroload://payment/cancel"
//
// Request body (JSON):
//   { "user_id": "<uuid>", "email": "<optional>" }
//
// Response (JSON):
//   { "url": "https://checkout.stripe.com/..." }
//   or { "error": "..." } on failure
// ─────────────────────────────────────────────────────────────────────────────

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
});

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { user_id, email } = await req.json();

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: "user_id is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const priceId = Deno.env.get("STRIPE_PRICE_ID");
    if (!priceId) {
      throw new Error("STRIPE_PRICE_ID environment variable is not set");
    }

    const successUrl = Deno.env.get("APP_SUCCESS_URL") ?? "neuroload://payment/success";
    const cancelUrl  = Deno.env.get("APP_CANCEL_URL")  ?? "neuroload://payment/cancel";

    // Create a Stripe Checkout Session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      mode: "payment",
      // EU digital goods — enable tax ID collection and automatic tax
      automatic_tax: { enabled: true },
      customer_email: email ?? undefined,
      // Pass user_id so the webhook can match the payment back to the user
      client_reference_id: user_id,
      metadata: { user_id },
      success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl,
      // 30-minute expiry — sensible for a mobile flow
      expires_at: Math.floor(Date.now() / 1000) + 30 * 60,
    });

    return new Response(
      JSON.stringify({ url: session.url }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.error("[create-checkout-session] Error:", message);
    return new Response(
      JSON.stringify({ error: message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
