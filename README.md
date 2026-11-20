# Inside Out Turf — Booking Website

A responsive React + Vite frontend preview for Inside Out Turf, Sodepur. Includes a photo-led venue landing page, football/box-cricket slot picker, date strip, multi-slot selection, estimated pricing, demo checkout, booking pass, My Bookings, tournaments/community preview, and owner dashboard.

## Run locally

```bash
npm install
npm run dev
```

Open the local URL printed by Vite. To create a production build:

```bash
npm run build
npm run preview
```

## What is real vs preview

- The uploaded night-time turf photo is stored locally in `public/images/inside-out-night.webp`.
- The gallery also references two public Inside Out Turf photos hosted by Playo. Keep attribution/usage rights in mind and replace with venue-approved originals before a commercial launch.
- Address, hours and email are based on the supplied business profile. The map button opens the Google Maps short link supplied by the user.
- Public third-party venue listings show Football and Box Cricket, 6:30 AM–10:30 PM, amenities, and a 4.8 Google rating. One public listing reports ₹475–₹650 per session; rates are marked as sample/unconfirmed in the app. Confirm exact rates, slot duration, phone number and cancellation policy with the owner.
- Booking records and offline blocks are stored in browser localStorage in preview mode. They are not shared across devices and do not prevent real-world double booking.
- Checkout is a demo only. It does not collect UPI/card payments. The confirmation is explicitly labelled as a demo pass.
- Tournaments, community posts and sample reviews are illustrative placeholders.

## Supabase setup

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the SQL editor.
3. Copy `.env.example` to `.env.local` and fill in the project URL and anon key.
4. Configure authentication, admin-only policies, server-side booking creation, and slot availability reads before going live.

**Important:** The included frontend currently demonstrates the Supabase insert path only. Production must call a trusted Edge Function/API that validates pricing and availability and invokes `create_booking_with_slots`. Do not let an unauthenticated browser call the `SECURITY DEFINER` RPC directly. Add strict RLS policies and restrict function execution to authenticated/verified callers.

## Razorpay payment integration

To collect real payments, create a Razorpay account and use a server/Edge Function to create an order. Keep the Razorpay secret on the server only. The browser should receive the order ID and public key, open Razorpay Checkout, then send the payment ID/order ID/signature to a server endpoint for signature verification. Confirm the booking only after server-side verification and a verified webhook. Add idempotency and refund/cancellation handling. Never mark a booking paid based only on a client-side success callback.

## Before publishing

- Get owner approval for all photos, pricing, slot lengths, phone number, amenities, rating/review claims and cancellation terms.
- Replace demo testimonials and tournament/community cards with verified information or remove them.
- Add real owner login and role-based access to `/admin`.
- Implement temporary 5-minute holds in the backend, with automatic expiry, plus atomic slot reservation using the included unique slot constraint/RPC pattern.
- Add booking confirmation email/SMS/WhatsApp integration only with consent and a provider.
- Configure custom domain, HTTPS, monitoring and backups.
