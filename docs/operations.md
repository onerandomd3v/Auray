# Deployment and recovery standard

## Target topology
One client-provided VPS with Docker Compose and Caddy serving independently deployable storefront, admin and API; PostgreSQL privately networked. Cloudflare proxies DNS and fronts the three application origins; R2 serves authorized product media. Never expose PostgreSQL or app internal ports publicly.

## Environments
Local dev, CI, and production. No permanent staging infrastructure required; use isolated integration tests and Bachs/SendByte sandbox. No production credentials in PRs or CI logs.

## Releases
Build immutable tagged images, require green PR checks, review Drizzle migration SQL, take a verified backup before risky production migrations, deploy only affected services, and smoke-test storefront, admin auth, API health, Bachs and SendByte integration configuration. Never automatically deploy from unreviewed PR code.

## Backups
Daily encrypted PostgreSQL backups to storage separate from VPS; initial retention: seven daily and four weekly copies. Verify restore before launch and periodically; document RPO/RTO after infrastructure inspection. Back up media as required separately (R2 is storage, not by itself a backup strategy). Monitor backup failures, disk capacity, HTTP availability and reconciliation backlog.

## Incidents
- Webhook delivery failed during outage: reconcile pending Bachs attempts, idempotently apply verified receipts, never charge twice.
- Reservation timed out: check provider payment/checkout state before stock release; late money and unavailable stock go to review.
- Deployment rollback: roll back to previously working container image; DB schema migrations may need forward-fix or tested restore, not blind rollback.
- Admin account compromise: revoke sessions, rotate credentials/secrets, audit changes and investigate.
