# Engineering decisions register

Approved by project owner. This document mirrors the approved Auray TDD and follow-up architecture approvals; the approved TDD/PRD govern any conflict.

| Area | Approved decision |
| --- | --- |
| Applications | Independent Next.js storefront and admin; NestJS REST API, pnpm monorepo |
| Runtime/data | Node.js 24; PostgreSQL + Drizzle; TypeScript |
| Repository | Only `main` permanent; short-lived PR branches and squash merges; no Linear yet |
| Inventory | Size/colour variant stocks, transactional reservations, safe release/reconciliation |
| Payments | Bachs checkout, verified signed webhooks, idempotency, audit ledger; product amount separate from shipping |
| Currencies | NGN is authoritative catalogue price; international options depend on verified Bachs capabilities |
| Delivery | Owner arranges, quotes, collects and manages delivery fees outside website |
| Checkout | Guest checkout; name, email, phone, address; mandatory published policy checkbox; no OTP/customer accounts |
| Policies | Admin-managed versioned policies; record accepted version at checkout |
| Guest privacy | Unpredictable private read-only order token; no access based only on order ID |
| Admin | Single owner, host-only server-managed sessions, Argon2id; API authorization, CSRF/origin checks, rate limits |
| Email | SendByte through EmailSender adapter; PostgreSQL transactional outbox, retries/dedupe, signed webhooks, delivery status |
| Storage | Cloudflare R2 via narrow object-storage adapter; private authorized uploads and product media domain |
| Edge/infra | Cloudflare DNS/proxy/WAF, strict TLS/origin protection, Caddy, Docker Compose on client-provided VPS |
| Delivery operations | Independent service deployments; reviewed Drizzle migrations, CI, daily encrypted backups and restore testing |
| Portability | Provider adapters only for external payments, email and object storage; no speculative stack abstraction |

## Open provider-dependent verification — NOT approved assumptions
1. Bachs sandbox: real checkout `expires_at`, payment method settlement windows, delayed/late webhook reconciliation; do not lock a 15-minute reservation without proof.
2. Bachs sandbox: NGN-authoritative catalogue with international checkout/currency conversion options and merchant capability constraints.
3. Bachs account/API: validate webhook types, signature verification, idempotency/retrieval semantics, refunds/disputes in test environment.
4. SendByte sandbox and production: SDK behaviour, DNS verified sender, persistent idempotency handling, signed delivery webhooks.
5. Host/domain delivery: inspect VPS capacity and firewall/Cloudflare origin setup before applying a production configuration.

## Scope governance
The owner-approved later changes (required email, transactional notifications, international payment option and admin policy updates) must be reconciled against the signed PRD/SOW before delivery claims or change-cost assumptions. Do not silently expand contract terms.
