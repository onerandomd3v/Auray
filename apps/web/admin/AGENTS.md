# Admin agent instructions

Inherit root `AGENTS.md`. This is a **separate**, independently deployable Next.js app for one Auray owner.
- Keep owner session cookies host-only; use server-side BFF where established and enforce authorisation again in NestJS.
- Never expose internal API credentials, R2 signing keys, password hashes or session tokens to the browser.
- Admin covers catalogue, variant stock, orders, fulfilment, policy draft/preview/publish, notifications, and **owner-initiated product refunds through secured NestJS/Bachs endpoints**. No direct SQL, direct provider secrets or manual modification of authoritative payment status.
- All privileged writes require CSRF/origin protection, explicit validation, suitable confirmations and audit logging.
- Do not make `Paid` a manually editable UI status or conflate delivery fee with product payment. Delivery quotes/payments are recorded manually, never collected through the site. Refund submission must require explicit confirmation, remain separate from original payment state, and display actual provider status.
- Follow approved brand assets; test login/session, destructive changes, product variants, policy publishing and accessibility.

- Use Tailwind CSS v4 utilities for application styling; keep only the necessary global CSS and await approved brand tokens. Do not introduce CSS frameworks or component libraries without approval.
