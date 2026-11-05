# Approved product requirements — Auray

**Status: approved product direction.** This is a non-commercial, code-facing summary of the signed Auray PRD and follow-up approved engineering decisions consolidated in the approved TDD dated 5 November 2026. This document is an implementation reference, not a replacement for the signed contract or an authorization to publish client-private documents.

## Customer journey
1. Customers browse physical fashion products by category, see product images and size/colour variants, and select variants with accurate per-variant in-stock/out-of-stock availability.
2. The cart and checkout use authoritative API prices and stock. Customers check out **as guests only** (no accounts or mandatory email/phone OTP).
3. Required checkout contact details: name, email, phone number and delivery address. Provide an explicit review/confirmation of entered information.
4. Display the active published business policies and require an **unchecked-by-default**, affirmative acceptance before placing an order; record the accepted immutable policy version and timestamp.
5. **Only product value is paid on the website** via Bachs. Explain clearly before payment that delivery charges are excluded, quoted and collected separately by the owner **outside** the website.
6. On order creation/payment, provide a unique order reference and a secure read-only receipt/order summary that can be printed or downloaded. Do not treat a publicly known order ID as authorization.
7. Send transaction-related emails via SendByte for meaningful order/payment/delivery states. Email delivery failure cannot invalidate a valid order or verified payment.
8. Never subscribe a customer to marketing automatically on the basis of transaction or policy acceptance.

## Catalogue and stock
- Owner manages categories, products, images, size/colour variants and **inventory per variant** through a separate authenticated admin dashboard.
- Use clear out-of-stock labels. Prevent negative/oversold quantities using PostgreSQL transactional reservation logic and explicit invariants.
- Store immutable product/variant/price snapshots on historical order items even if catalogue data later changes.

## Money, payments, inventory and fulfilment
- Catalogue/accounting base currency is **NGN**; represent NGN order amounts as integer kobo. Keep any provider-side foreign-currency payment and settlement data exactly and separately; never round floating point currency conversions casually.
- International customers may be supported via **actual Bachs merchant capabilities**, which must be verified in sandbox/account configuration. Never advertise a payment method/currency that has not been verified.
- Customer product payment is initiated through Bachs' provider-specific adapter. Successful redirect/checkout-completion is **not proof of collected funds**. Mark paid only after an authoritative verified Bachs result matches the order reference and the exact expected provider-side amount and currency recorded for that payment attempt.
- For any enabled non-NGN checkout, persist the provider-side currency, exact amount representation in provider-defined units, and the applicable exchange quote/conversion basis **before payment initiation**, linked to the NGN order total and payment attempt. On confirmation, reconcile the authoritative provider amount/currency and reference against that stored tuple; preserve the mapping and quote basis in the audit ledger. Never compare a non-NGN provider payment amount directly to an NGN order total or infer a rate retroactively.
- Checkout/order/reservation/payment attempts are distinct records and state machines. Make provider webhook processing idempotent and auditable; handle retries, duplicate/out-of-order events, underpayments and disputes.
- A stock reservation cannot be released based solely on a guessed 15-minute timeout. Confirm checkout closure/expiry and no successful payment using Bachs. Late paid orders after released inventory require atomic reallocation or ON_HOLD/manual resolution; never oversell.
- Owner handles delivery, contacts buyers, arranges dispatch and **quotes and collects delivery fees entirely outside the website**. The admin may record delivery notes, quotes and a manual delivery-payment status, but never initiates or collects delivery payment. Product payment, manual delivery-payment records and fulfilment are distinct.
- Customers contact Auray through official support channels for return, exchange or refund requests; **there is no customer-facing refund application, account or portal**. The owner reviews eligibility and initiates eligible product-payment refunds **from the admin dashboard through NestJS and the Bachs payment adapter**. A refund request is not completion: retain original charge data and independently track requested/pending/succeeded/failed provider refund states, amount/currency and audit events. Verify Bachs merchant permissions, refund limits and confirmation mechanisms in sandbox before implementation. The store’s voluntary-return policy does not override statutory consumer rights.

## Owner workflow
- Single-owner dashboard with secure login/session, explicit server-side authorization and audit logging.
- Owner creates/edits products, variants, stock and policies, views/orders and records fulfilment progress. Do not allow the UI to forge a paid state.
- Owner edits policy drafts, previews the public Business Policies page, and explicitly publishes a version from the admin dashboard. The storefront displays the **currently published immutable policy version**; the backend stores its exact text/version and acceptance timestamp against each order. Publishing another version affects future checkouts only; previously placed orders retain their accepted version. If a newer version publishes before an order is submitted, require review and acceptance of the newly active version before creating the order. Initial owner-supplied policy copy remains **pending owner approval**; the open draft `docs/business-policy.md` is not a published policy.

## Provider integration
- **Bachs**: narrow PaymentGateway interface for checkout, signed events, server reconciliation **and owner-authorized refunds**; authenticate and reconcile refund outcomes against the originating product payment with idempotency and exact amounts/currencies. Provider refund API support and merchant permissions must be verified before coding against them.
- **SendByte**: narrow EmailSender interface, official Node.js SDK, verified sender domain, PostgreSQL transactional outbox, stable idempotency keys, retries and signed delivery webhooks.
- **Cloudflare R2**: narrow ObjectStorage interface, controlled uploads and public product-media delivery; do not expose storage credentials to browsers.
- This is **provider portability**, not a mandate to abstract PostgreSQL, Drizzle, NestJS or Next.js.

## Operational and security acceptance
- Independent Next.js storefront and admin, NestJS REST API, PostgreSQL/Drizzle, Node 24, pnpm, Tailwind CSS 4, Docker Compose/Caddy on client-supplied VPS, Cloudflare proxy/WAF/TLS/origin controls.
- Secure private guest order links, host-only HttpOnly admin cookies, Argon2id, CSRF/origin checks, login/checkout rate limiting, redacted logs and no publicly exposed PostgreSQL.
- Reviewed migrations, independent CI, backup and tested recovery, integration tests covering concurrency, payment reconciliation, SendByte outbox and provider sandbox cases.

## Not in scope by default
Customer sign-up/account system, delivery payment in website checkout, automated logistics-provider integration, Redis/BullMQ, microservice split, and new external platform integrations without approval.

## Implementation-specific evidence gates (not new design approvals)
- Bachs checkout expiry/settlement/reconciliation, international payment support, and owner-initiated refund API/merchant capability and status confirmation.
- SendByte sandbox delivery, idempotency, signed event handling, domain DNS verification.
- Client VPS/domain/merchant account capabilities and verified backups/recovery.
- Reconciliation of later approved email/currency/policy-management changes with the signed PRD/SOW is a commercial project-management responsibility, not a license for engineering agents to delete the approved requirements.
