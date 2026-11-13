# Coding agent and subagent workflow

Codex reads `AGENTS.md` recursively. Project custom subagents are standalone TOML files in `.codex/agents/`; the project settings in `.codex/config.toml` select Luna as the primary model and enable bounded native delegation. Do not use a `subagents.md` file as executable configuration.

## Roles and ownership

- **Luna (`gpt-6-luna`, high)** is the implementation owner. Read the assigned Linear issue and governing repository documents, make routine implementation choices, implement, test, review the diff, and prepare a PR. Never merge automatically or change approved product/architecture decisions without authorization.
- **Sol (`gpt-6.1-sol`, high)** is an on-demand technical architect for consequential questions. Sol investigates code and specifications, evaluates options against approved constraints, and returns actionable guidance. Luna remains responsible for implementation, verification, and PR preparation.
- Existing `architecture-reviewer`, `security-reviewer`, and `test-reviewer` agents remain available for focused reviews. Do not add another agent to routine work.

The native interface is enabled and capped at two concurrent subagents per session. Select Luna explicitly when starting an implementation session if the current client does not honor the project model setting; do not silently substitute a model. Select Sol by agent name for consequential analysis.

## When Luna asks Sol

Escalate only when at least one of these applies:

- Two or more viable approaches carry meaningful architectural consequences.
- A decision affects money, stock consistency, payment reconciliation, or security.
- Migration or concurrency correctness has a nontrivial risk.
- Existing code conflicts with approved requirements or another engineer's ownership.
- A difficult failure remains after reasonable local investigation.

Do not delegate routine DTOs, standard validation, straightforward UI changes/tests, or small refactors. Luna should first inspect the relevant code, docs, tests, and failure output. If Sol identifies a genuinely new product/architecture decision, pause only that decision, notify the engineering lead, and continue unrelated safe work.

## Escalation task packet

Send a concise native subagent message containing:

1. Linear issue and current objective.
2. Precise technical question and the decision needed.
3. Relevant file paths and current implementation state.
4. Approved constraints and invariants.
5. Viable approaches already considered and their tradeoffs.
6. Evidence, commands/tests, and failures observed.
7. Requested output: recommendation, steps, risks, tests, external evidence, and approval need.

Avoid persistent packet files for routine escalations. Record consequential approved decisions in the issue or existing decision register.

## Sol response format

Sol returns: recommended approach; rationale and material tradeoffs; implementation steps for Luna; security/integrity risks; required tests and verification; unresolved external evidence; and whether engineering-lead approval is needed. Luna checks the recommendation against approved documents, incorporates it when authorized, then resumes implementation and owns all validation.

## Boundaries and review

Sol is instructed not to edit application files, commit, create PRs, or override approved decisions. **This is an advisory instruction, not enforced read-only access:** custom agents inherit the parent session's filesystem and approval permissions, and the installed client does not provide a per-agent read-only permission override. Keep Sol's work to investigation and recommendations; Luna owns all edits. Use the repository's normal worktree and ownership rules for any parallel work. Never expose production credentials or customer data.

Luna follows the root [`AGENTS.md`](../AGENTS.md) Git rules: assigned issue IDs only, short-lived approved-prefix branches, reviewed PRs to `main`, and no automatic merge. The parent owns final review, validation evidence, and PR preparation.

## Start a Luna implementation session

1. Start Codex in this trusted Auray project and select `gpt-6-luna` with High reasoning (the project config requests these defaults).
2. Before proceeding, have the primary session read `.codex/agents/luna.toml` and follow its authorization rule: do not commit, push, or open a PR unless explicitly asked. Then state the assigned Linear issue ID and objective, and read root `AGENTS.md`, this workflow, the relevant product/architecture/security docs, and applicable nested instructions before editing.
3. Ask Luna to implement the issue independently, run relevant checks, review its diff, and prepare—not merge—a focused PR.
4. Ask Luna to delegate to `sol` only if an escalation criterion above is met, using the task packet format. Luna should return with the recommendation and continue.

## Troubleshooting

- Check `codex --version`, then run `codex debug models` and confirm `gpt-6-luna` and `gpt-6.1-sol` appear in the model catalog. Availability can still depend on account/client rollout.
- If the project is untrusted, trust it only through the Codex UI after reviewing its configuration; project-local settings may otherwise be ignored.
- If delegation is unavailable, inspect `codex features list` and the effective `[agents]` settings. Current Codex releases enable native subagents by default; this project explicitly enables them and caps concurrent subagent threads at two.
- If the requested model is absent or rejected, stop and report the exact compatibility issue. Do not silently substitute another model or edit global user configuration.
- Custom agents inherit parent sandbox and approval settings. Do not claim Sol is technically sandboxed read-only.
