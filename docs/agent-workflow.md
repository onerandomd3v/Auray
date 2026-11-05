# Coding agent and subagent workflow

Codex reads `AGENTS.md` recursively in the directory hierarchy. Do not use a file named `subagents.md` as if Codex automatically executes it; project-specific custom subagent definitions live under `.codex/agents/*.toml`.

## Default execution
One responsible implementation agent per worktree and focused task. Read the assigned requirements and relevant code, implement, validate, inspect the diff, and open a PR to `main`. The root [`AGENTS.md`](../AGENTS.md) owns branch naming, approvals, and merge rules. Never touch production without explicit authorization.

## Optional specialists
- `architecture-reviewer`: read-focused review of boundaries and decisions.
- `security-reviewer`: adversarial review of sessions, payment, webhooks and guest privacy.
- `test-reviewer`: independent test gaps, integration/CI evidence and regressions.

Only delegate when parallel read-heavy work adds value. Specialists must report findings and evidence, not silently alter code; their instructions **do not enforce a read-only sandbox**. Ensure no two agents edit the same worktree. Parent agent owns final validation and reporting.

See OpenAI's Codex AGENTS.md and subagent documentation for instruction discovery and TOML format.
