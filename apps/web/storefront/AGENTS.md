# Storefront agent instructions

Inherit root `AGENTS.md`. This is the **public** Next.js application, deployed independently of the owner admin.
- Public browsing, categories, variants, cart, guest checkout, policy acceptance and private read-only order confirmation belong here.
- Never implement authoritative prices, stock decrements, payment verification, privileged auth or direct DB access in this app.
- Always request server-calculated checkout totals; do not expose guest order details using only an order number.
- Use accessible responsive Next.js patterns; do not invent Auray branding until designer-approved assets exist.
- Treat private guest token URLs as secrets: no analytics/referrer exposure, `no-store`, careful logging.
- Add tests for changes and run the app's real lint/typecheck/test/build commands when available; never claim scaffold checks are app tests.

- Use Tailwind CSS v4 utilities for application styling; keep only the necessary global CSS and await approved brand tokens. Do not introduce CSS frameworks or component libraries without approval.
