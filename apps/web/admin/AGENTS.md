# Admin agent instructions

Inherit root `AGENTS.md`. This is a **separate**, independently deployable Next.js app for one Auray owner.
- Keep owner session cookies host-only; use server-side BFF where established and enforce authorisation again in NestJS.
- Never expose internal API credentials, R2 signing keys, password hashes or session tokens to the browser.
- Admin covers catalogues, size/colour variants and stock, orders, fulfilment, policies, and notifications; no direct SQL or provider payment override.
- All privileged writes require CSRF/origin protection, explicit validation, suitable confirmations and audit logging.
- Do not make `Paid` a manually editable UI status or conflate delivery fee with product payment.
- Follow approved brand assets; test login/session, destructive changes, product variants, policy publishing and accessibility.
