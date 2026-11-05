# API agent instructions

Inherit root `AGENTS.md`. NestJS is the single domain/business authority.
- Modular monolith; thin REST controllers; application/domain boundaries; validated DTOs and explicit errors.
- PostgreSQL + Drizzle; reviewed migrations, unique constraints, indexes and transactions. Never run production migrations automatically at startup.
- Money: authoritative NGN amounts in integer kobo; convert exactly at provider boundary and verify actual payment amount/currency.
- Concurrency: reservation, allocation and payment transitions must be atomic and idempotent. Tests must cover two purchasers competing for last stock.
- External adapters: `PaymentGateway` (Bachs checkout, reconciliation and owner-initiated refunds), `EmailSender` (SendByte), `ObjectStorage` (R2); isolate SDK/event specifics. Refund API and merchant permissions require sandbox verification. Do not abstract Drizzle/Next/Nest.
- Verify Bachs and SendByte webhook signatures over original bytes, dedupe provider events and persist audit history.
- Email outbox saved in same DB transaction as business events; retry asynchronously, no checkout blocking on email failure.
- Enforce server sessions, role checks, CSRF, login throttling, guest access tokens, policy version acceptance and private-order no-store. Publish immutable policy versions from admin, persist exact acceptance per order, prevent stale-policy checkout. Refunds originate only from owner-authorized API actions, are idempotent/audited and remain pending until Bachs confirms outcome.
- Secrets never in client bundles or logs. Test against real PostgreSQL for DB and payment invariants.
