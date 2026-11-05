# Security boundaries

- Single-owner admin account with Argon2id passwords, hashed opaque DB session tokens, Secure/HttpOnly/host-only cookie on admin origin, revocation, throttling and secure recovery. Use the TDD's 12-hour admin inactivity timeout starting configuration; changes require an explicit documented security rationale and approval.
- Separate browser-to-admin BFF boundary and server-to-Nest API boundary. NestJS independently authorizes every privileged call. Prevent cookie forwarding to unrelated subdomains. Enforce CSRF/origin checks for state-changing requests.
- Guest order ID is a reference, not authorization. Use a long random read-only access token, store its hash, avoid logging/link referrer leakage; `Cache-Control: no-store` and secure reissue procedures.
- Never expose order/customer data from public API without authorization. Validate all fields and reject untrusted amounts/stock/client-supplied paid flags.
- Bachs: authenticate raw-body webhook signatures, match merchant/order/amount/currency, unique event IDs and reconciliation before confirming paid. Do not allow UI to mark orders paid.
- SendByte: use backend API keys, signed lifecycle webhooks, stable idempotency keys and retryable PostgreSQL outbox.
- R2: authenticated uploads, content-type/magic/size restrictions, private key storage, short-lived scoped presigned URLs, controlled public media.
- Cloudflare proxied records, Full strict TLS, origin bypass mitigation, firewall, restricted SSH, no public DB/containers; app-level throttling complements WAF.
- No personal data, secrets, passwords, webhook bodies with sensitive data, or tokens in logs. Prefer structured redacted logging and minimum necessary retention.
- Checkout business-policy agreement must be affirmative (unchecked by default), linked and versioned; acceptance recorded with order. Policy acceptance does not waive statutory rights.
