# Deployment notes

## Quick static preview (GitHub Pages / Netlify / Vercel)

This is a Vite app. Build command: `npm run build`; output directory: `dist`.

For GitHub Pages, set the Vite `base` option in `vite.config.js` to your repository path if deploying under `username.github.io/repository-name/`. For a custom domain or Netlify/Vercel root deployment, use `/`.

## Production booking checklist

A public static website alone cannot securely run live payments or guarantee availability. Before advertising online booking:

1. Deploy a server-side API or Supabase Edge Functions.
2. Implement a five-minute hold record with `hold_expires_at`, server-side expiry cleanup, and unique slot reservation.
3. Use one database transaction for all slots selected in a booking.
4. Calculate final price on the server from owner-controlled pricing rules.
5. Integrate Razorpay Orders + server-side signature verification + webhook verification.
6. Only then create/confirm the booking and send a real confirmation.
7. Protect `/admin` using Supabase Auth and role-based authorization. The current admin screen is intentionally a demo and has no login.
