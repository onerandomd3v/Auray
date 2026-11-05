# Verification and test standard

## Build gates
Each PR requires applicable lint, TypeScript checks, focused tests and builds. All four GitHub Actions checks must pass on the current PR revision; never infer that scaffold tests cover unimplemented commerce functionality.

## Domain tests expected as functionality lands
- **Inventory:** concurrent last-unit reservations; duplicate releases; variant availability; no negative stock; correct item snapshots.
- **Checkout/policies:** required email/phone/address, server-side price validation, unauthorized cart manipulation and idempotency; owner draft/preview/publish, only active policy displayed publicly, immutable historic versions, correct order acceptance timestamps and rejection of stale acceptance when the active version changes.
- **Payments/refunds:** signature verification, wrong amount/currency, duplicated/out-of-order/late Bachs events, underpayment, dispute, post-outage reconciliation, exactly-once stock consumption; owner-only refund initiation, amount/currency/refundable-balance constraints, duplicate submission/idempotency, provider pending/success/failure reconciliation and audit preservation. Refund API functionality is subject to Bachs sandbox validation.
- **Email:** SendByte stable idempotency keys, outbox transaction atomicity, retries with lease, signed webhooks, provider downtime never reverting payment.
- **Admin:** secure session creation/revocation/inactivity, authorization enforcement through API, CSRF/origin checks, login throttling, audit.
- **Guest:** token expiry/revocation, order reference not authorization, no private caching or token leakage.
- **Media:** constrained R2 uploads, type/size verification, authorization and safe object naming.
- **Operations:** independent deploy rollback/smoke checks, backup restore evidence, origin restriction and reconciliation recovery.

## Required test environment discipline
Use a real isolated PostgreSQL instance for transaction/concurrency/migration integration tests. Bachs and SendByte tests start in sandboxes with synthetic customer data. Production credentials and customer data are not test fixtures.

## PR evidence
Include commands actually run, outcomes, changed behaviour, tests added and provider dependencies. Open questions must be classified as missing external evidence, not a presumed reopening of approved architecture.
