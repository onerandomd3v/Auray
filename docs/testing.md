# Verification and test standard

## Build gates
Each PR requires applicable lint, TypeScript checks, focused tests and builds. All four GitHub Actions checks must pass on the current PR revision; never infer that scaffold tests cover unimplemented commerce functionality.

## Domain tests expected as functionality lands
- **Inventory:** concurrent last-unit reservations; duplicate releases; variant availability; no negative stock; correct item snapshots.
- **Checkout:** required email/phone/address, policy version acceptance, server-side price validation, unauthorized cart manipulation, idempotent creation.
- **Payments:** signature verification, wrong amount/currency, duplicated/out-of-order/late Bachs events, underpayment, dispute, post-outage reconciliation, exactly-once stock consumption.
- **Email:** SendByte stable idempotency keys, outbox transaction atomicity, retries with lease, signed webhooks, provider downtime never reverting payment.
- **Admin:** secure session creation/revocation/inactivity, authorization enforcement through API, CSRF/origin checks, login throttling, audit.
- **Guest:** token expiry/revocation, order reference not authorization, no private caching or token leakage.
- **Media:** constrained R2 uploads, type/size verification, authorization and safe object naming.
- **Operations:** independent deploy rollback/smoke checks, backup restore evidence, origin restriction and reconciliation recovery.

## Required test environment discipline
Use a real isolated PostgreSQL instance for transaction/concurrency/migration integration tests. Bachs and SendByte tests start in sandboxes with synthetic customer data. Production credentials and customer data are not test fixtures.

## PR evidence
Include commands actually run, outcomes, changed behaviour, tests added and provider dependencies. Open questions must be classified as missing external evidence, not a presumed reopening of approved architecture.
