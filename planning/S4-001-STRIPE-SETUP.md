# S4-001 — Stripe Checkout: Implementation Guide

## What was built

### Supabase Edge Functions

| File | Purpose |
|------|---------|
| `supabase/functions/create-checkout-session/index.ts` | Creates a Stripe Checkout Session and returns the URL |
| `supabase/functions/stripe-webhook/index.ts` | Receives Stripe webhook events and marks user as paid |

### Flutter changes

| File | Change |
|------|--------|
| `lib/screens/paywall/paywall_screen.dart` | Replaced TODO stub with real Stripe Checkout flow |

---

## Deploy Steps

### 1. Install Supabase CLI (if not already)
```bash
npm install -g supabase
supabase login
supabase link --project-ref <YOUR_PROJECT_REF>
```

### 2. Create the Stripe product & price
1. Go to Stripe Dashboard → Products → Add Product
2. Name: "NeuroLoad Lifetime"
3. Price: €49, one-time
4. Copy the **Price ID** (starts with `price_...`)

### 3. Set Edge Function secrets
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_live_...
supabase secrets set STRIPE_PRICE_ID=price_...
supabase secrets set APP_SUCCESS_URL=neuroload://payment/success
supabase secrets set APP_CANCEL_URL=neuroload://payment/cancel
```

### 4. Deploy the Edge Functions
```bash
# create-checkout-session requires JWT (called from the app with anon key)
supabase functions deploy create-checkout-session

# stripe-webhook must skip JWT verification (Stripe doesn't send a JWT)
supabase functions deploy stripe-webhook --no-verify-jwt
```

### 5. Register the Stripe webhook
1. Stripe Dashboard → Developers → Webhooks → Add endpoint
2. URL: `https://<YOUR_PROJECT_REF>.supabase.co/functions/v1/stripe-webhook`
3. Events to listen for:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
4. Copy the **Signing secret** (starts with `whsec_...`)
5. Add it:
```bash
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_...
```

### 6. Create the `user_licences` table in Supabase
Run in the Supabase SQL editor:
```sql
CREATE TABLE IF NOT EXISTS public.user_licences (
  user_id           uuid PRIMARY KEY,
  is_paid           boolean DEFAULT false NOT NULL,
  paid_at           timestamptz,
  stripe_session_id text
);

-- Service role can insert/update (used by the webhook function)
ALTER TABLE public.user_licences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "service_role_all" ON public.user_licences
  FOR ALL USING (auth.role() = 'service_role');
```

### 7. Wire the deep-link callback (Flutter side)

After the user pays, Stripe redirects to `neuroload://payment/success?session_id=...`.
The app needs to handle this URI and verify + mark paid.

**Android** — add to `android/app/src/main/AndroidManifest.xml` inside `<activity>`:
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="neuroload" android:host="payment" />
</intent-filter>
```

**iOS** — add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>neuroload</string>
    </array>
  </dict>
</array>
```

**Flutter** — add `app_links` package and listen in `main.dart`:
```dart
// In main() or in a top-level widget's initState:
final appLinks = AppLinks();
appLinks.uriLinkStream.listen((uri) {
  if (uri.scheme == 'neuroload' && uri.host == 'payment') {
    if (uri.path == '/success') {
      // Poll Supabase user_licences or call a verify-payment edge function
      // then call ref.read(isPaidProvider.notifier).markPaid();
    }
  }
});
```

---

## Test with Stripe test mode
1. Use `sk_test_...` key and a test Price ID
2. Use Stripe's test card: `4242 4242 4242 4242`, any future expiry, any CVC
3. Confirm the webhook fires and `user_licences` is updated in the Supabase table viewer

---

## Current behaviour without deployment
- The "UNLOCK NEUROLOAD" button calls `create-checkout-session`
- If Supabase credentials are not set in Settings, shows a friendly error
- Voucher code path still works as a fallback (any 8-char code)
