import { createClient } from "jsr:@supabase/supabase-js@2";


const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authorization = req.headers.get("Authorization");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const stripeSecret = Deno.env.get("STRIPE_SECRET_KEY");
  if (!authorization || !supabaseUrl || !anonKey || !serviceRoleKey || !stripeSecret) {
    return json({ error: "Payment service is not configured" }, 500);
  }
  if (!/^Bearer\s+\S+$/i.test(authorization)) {
    console.warn("create-booking-payment: missing or malformed bearer token");
    return json({ error: "Authentication required" }, 401);
  }

  try {
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
      auth: { persistSession: false },
    });
    // Validate the access token from the request explicitly. Supplying it as
    // getUser(token) avoids relying on the client's internal auth state.
    const accessToken = authorization.replace(/^Bearer\s+/i, "").trim();
    const { data: { user }, error: authError } = await userClient.auth.getUser(accessToken);
    if (authError || !user) {
      console.warn("create-booking-payment: access token rejected", authError?.message ?? "user not found");
      return json({ error: "Authentication required" }, 401);
    }

    const { bookingId } = await req.json();
    const id = Number(bookingId);
    if (!Number.isSafeInteger(id) || id <= 0) return json({ error: "Invalid bookingId" }, 400);

    const admin = createClient(supabaseUrl, serviceRoleKey, { auth: { persistSession: false } });
    const { data: booking, error: bookingError } = await admin
      .from("booking")
      .select("id, customer_id, status, price, payment_intent_id, payment_status")
      .eq("id", id)
      .maybeSingle();
    if (bookingError) throw bookingError;
    if (!booking || booking.customer_id !== user.id) return json({ error: "Booking not found" }, 404);
    if (booking.status !== "pending") return json({ error: "Booking is not payable" }, 409);

    const amount = Math.round(Number(booking.price) * 100);
    if (!Number.isSafeInteger(amount) || amount <= 0) return json({ error: "Booking has no valid price" }, 400);
    if (booking.payment_status === "succeeded") return json({ error: "Booking is already paid" }, 409);

    let intent: Record<string, unknown>;
    if (booking.payment_intent_id) {
      const response = await fetch(`https://api.stripe.com/v1/payment_intents/${booking.payment_intent_id}`, {
        headers: { Authorization: `Bearer ${stripeSecret}` },
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error?.message ?? "Could not retrieve payment");
      intent = result;
      if (intent.amount !== amount || intent.currency !== "nzd") {
        return json({ error: "Booking amount changed; contact the clinic" }, 409);
      }
    } else {
      const form = new URLSearchParams({
        amount: String(amount), currency: "nzd", "automatic_payment_methods[enabled]": "true",
        "metadata[booking_id]": String(id), "metadata[customer_id]": user.id,
      });
      const response = await fetch("https://api.stripe.com/v1/payment_intents", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${stripeSecret}`,
          "Content-Type": "application/x-www-form-urlencoded",
          "Idempotency-Key": `booking-${id}`,
        },
        body: form,
      });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error?.message ?? "Could not create payment");
      intent = result;
      const { error: updateError } = await admin.from("booking").update({
        payment_intent_id: intent.id,
        payment_status: "requires_payment_method",
      }).eq("id", id).eq("customer_id", user.id);
      if (updateError) throw updateError;
    }

    if (typeof intent.client_secret !== "string") throw new Error("Stripe did not return a client secret");
    return json({ clientSecret: intent.client_secret, paymentIntentId: intent.id });
  } catch (error) {
    console.error("create-booking-payment failed", error);
    return json({ error: "Could not prepare payment" }, 500);
  }
});
