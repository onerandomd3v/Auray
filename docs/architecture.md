# Architecture

## System
Auray is a **pnpm/TypeScript monorepo** with three independently buildable/deployable applications:

```text
apps/
  web/
    storefront/  Next.js customer commerce UI
    admin/       Next.js single-owner management UI
  api/           NestJS modular-monolith REST API and webhooks
packages/       Only genuinely shared contracts/configuration
infra/          Deployment manifests and scripts as implemented
docs/           Engineering standards, decisions and operations
```

Example public hostnames for configuration (actual domain/subdomains depend on the client's DNS; this is not an architecture approval gap): apex/www for storefront, `admin.<domain>` for admin, `api.<domain>` for API, `media.<domain>` for public product images.

Cloudflare fronts HTTP application traffic (DNS, proxy, WAF, Full strict TLS). Caddy routes on the client VPS to Docker Compose services. PostgreSQL stays private. R2 stores product images. Bachs handles product checkout. SendByte delivers transactional email. Neither Next.js app accesses PostgreSQL directly.

## Responsibilities
- **Storefront:** public product catalogue, variant selection, cart, guest checkout, policy checkbox, secure confirmation and receipts.
- **Admin:** one owner manages categories/products/variant stock, published policies, order/delivery progress and delivery notes.
- **NestJS:** authoritative money, validation, guest/order access, business rules, stock reservations, payment event reconciliation, admin auth, email outbox, signing and provider adapters.
- **Database:** order snapshots, exact inventory/reservation state, payment attempts/webhook event ledger, policy versions, audit records and notification outbox.

## Domain lifecycle
Payment, fulfilment and reservation state machines are distinct. `checkout.completed` does not mean `Paid`. A verified Bachs successful collection plus matching order/currency/amount is required. Duplicate/out-of-order webhooks and late payments must be idempotent. A reservation cannot be released solely on a guessed timer; see [decisions](decisions.md).

Delivery fees are quoted and paid **outside** the website. The product checkout amount excludes delivery and must disclose this before payment.

## Portability
Use narrow internal interfaces for payment, transactional email and object storage. Keep provider-specific capability handling and signed event normalization in adapters. Do not make framework, ORM or database portable for its own sake.

## Decision and implementation status
The architecture above is **approved**. The current repository implements application scaffolding only; catalogue, inventory, authentication, checkout, payments, emails, persistence and deployment are not yet built. Implementation state does not reopen these decisions. See [implementation readiness](implementation-readiness.md) and [product requirements](product-requirements.md).
