# Auray repository instructions

Read `README.md`, `docs/product-requirements.md`, `docs/architecture.md`, `docs/decisions.md`, `docs/development.md`, `docs/implementation-readiness.md` and relevant nested `AGENTS.md` before changes. The signed PRD and approved TDD govern product and architecture; repository Markdown translates their approved, non-commercial technical requirements into coding-agent instructions. Do not infer new requirements from unavailable documents or claim implementation equals approval.

## Repository and Git
- Canonical repository: `onerandomd3v/Auray`; target `main` only. No long-lived development branch.
- Use a short-lived branch with a **task-oriented prefix only**: `feat/`, `fix/`, `chore/`, `docs/`, `test/`, `refactor/`, `ci/`, or `security/` (e.g. `feat/AUR-123-catalogue-variants`, `docs/update-order-contract`). **Never create `codex/`, `agent/`, `ai/`, `dev/`, `develop/`, personal-name, or tool-name-prefixed branches**. Agent identity belongs in PR metadata, not the branch name. If an automation defaults to `codex/`, override the default before creating a PR. Do not rename an existing branch without coordination.
- One focused PR per change. Update the branch with latest `main` before merge; squash only, never push directly to `main`.
- Do not invent or automatically create Linear issues. Once the project backlog is approved, implement from assigned Linear issues and reference their identifiers in branch names and PRs. Until then, use a descriptive branch name without inventing an issue key.
- Never auto-merge; document checks actually run, risks, and relevant user-visible impact.
- Use separate Git worktrees for parallel implementation work; avoid multiple agents editing the same worktree.
- Preserve app boundaries: `apps/web/storefront`, `apps/web/admin`, `apps/api`; avoid unnecessary shared packages.
- Never change approved product or architecture decisions, introduce services, or reinterpret client policy without approval. `docs/decisions.md` explicitly distinguishes approved choices from provider sandbox verification.
- No secrets, private client documents, customer data, or credentials in Git; no production access or migrations without explicit authorization.

## Required technical choices
- Node.js 24, TypeScript, pnpm workspaces, standalone Next.js storefront and admin using Tailwind CSS v4, NestJS modular-monolith REST API, PostgreSQL + Drizzle ORM.
- Cloudflare proxied DNS/WAF, R2 media, client-provided VPS, Docker Compose, Caddy; provider adapters for Bachs, SendByte, object storage.
- Do not add Redis, queues, microservices, customer accounts, or shipping-provider integration by default.

## Safety and business invariants
- NestJS owns pricing, product/variant stock, guest orders, policy acceptance, authentication, payments and fulfilment. Browser data is untrusted.
- Product payment via Bachs; delivery quoted and paid outside the website. Do not confuse checkout completion with settled funds.
- Variant-level inventory reservations must be transactional and concurrency-safe. Provider expiry/late payment reconciliation is required before release.
- Verify signed Bachs webhook payloads and enforce idempotency, amount/currency matching and audit history.
- Email is required during guest checkout; no mandatory OTP. SendByte emails use an outbox and retries; email failures never reverse checkout/payment.
- Admin uses host-only HttpOnly Secure cookies and server-side authorization. Guest order access requires unguessable private read-only tokens.
- Protect sensitive endpoints from CSRF, abuse and data leaks; do not log secrets, tokens or personal data.

## Development and verification
- Look at existing code before editing, use reviewed Drizzle SQL migrations, test financial/inventory/security changes with real PostgreSQL where relevant.
- Never claim CI or tests pass unless actually run. Treat placeholder/scaffold checks as such.
- Follow approved brand/design artifacts when available; don't invent a design system.
- Read the closest nested `AGENTS.md` for app-specific instructions.

## References
- `docs/product-requirements.md`: approved product behaviours and acceptance invariants
- `docs/implementation-readiness.md`: decision authority, implementation status, validation gates and handoff
- `docs/architecture.md`: boundaries and deployable components
- `docs/decisions.md`: approved decisions, explicitly open validations
- `docs/development.md`: local setup, verification and Git workflow
- `docs/security.md`: authentication, checkout, webhook and data protection
- `docs/operations.md`: Cloudflare, VPS, backups, migrations and recovery
- `docs/agent-workflow.md`: optional specialist subagents, their authority and review

## Additional implementation references
- `docs/implementation-readiness.md`: approval versus implementation status and when an agent may request a decision
- `docs/testing.md`: testing and integration evidence requirements
