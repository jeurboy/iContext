# iContext agent mutation safety hook

This project requires an explicit user confirmation immediately before an AI agent performs any of
these actions:

1. `git commit`
2. `git push` (including normal and force pushes)
3. Direct database access, migration, seed, reset, import, restore, DB push, or another command
   known to read from or change a database environment

The agent must state the exact action, target, environment, and expected impact. Approval applies
only to the listed invocation. A later commit, push, DB command, migration, or seed requires a new
confirmation. A general request such as “continue”, “finish”, or “do it” is not approval for these
restricted actions unless it explicitly names them.

Editing migration, schema, or seed source files inside an already-authorized code change is not the
same as executing them against a database. Execution remains confirmation-gated.

## Hook wiring

If the active AI host supports a pre-command/pre-tool hook with an interactive `ask` or equivalent
permission decision, register [`guard-command.sh`](./guard-command.sh) for shell commands.

- Merge with existing project hook configuration; never overwrite unrelated hooks.
- Use the host's documented project-local configuration and payload format. Do not invent hook keys.
- Adapt the wrapper when the host expects a different input/output envelope, but preserve the three
  restricted action classes and per-invocation confirmation rule.
- Before enabling it, dry-run `git status` (must allow) and `git commit`, `git push`, a direct DB
  client, and a seed/migration command (must ask).
- After enabling it, verify through the host's real hook path, not only by running this script.

If the host has no interactive hook mechanism, do not install a permanent hook that can only
allow/block with no approval path. Keep the same policy in the L1 agent instructions and report
`hook unavailable; policy enforced by instructions`.

Hooks are defense in depth. A missing, disabled, failed, or bypassed hook never grants permission.
