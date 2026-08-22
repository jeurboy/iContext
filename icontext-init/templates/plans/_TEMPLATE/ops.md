# NNN · OPS (DevOps / Deploy) — <Feature Name>

> ref: [CONTEXT.md](../../CONTEXT.md) · **security:** [SECURITY.md](../../SECURITY.md) §8 · §11.6 · index: [README.md](./README.md)
> Owns: security/privacy posture, deploy, migrations, env.

## 8. Security & Privacy · `DEV QA OPS`
<!-- Authz, data protection, PII handling. Align with SECURITY.md §8 (auth model, roles, PII, secrets). -->

### 8.1 Security review (`security-review`) · `OPS DEV`
<!-- SECURITY.md §11.6. Record the real detector output, not a summary opinion. -->

**Plan phase — before `ready to implement`**

| Sub-skill | Run? | Findings (high/critical) | Outcome |
|-----------|------|--------------------------|---------|
| supply-chain | <!-- yes/no --> | <!-- count / none --> | <!-- fixed / accepted (reason) --> |

**Implement phase — per slice (§11.5 step 5.5)**

| Sub-skill | Applies when | Run? | Findings | Outcome |
|-----------|--------------|------|----------|---------|
| secret | always | | | |
| code-review | always | | | |
| auth | authn/authz, session, token, role changes | | | |
| dependency | manifest / lockfile changed | | | |
| docker | Dockerfile / compose / base image changed | | | |

<!-- Ad hoc only (not in the default lifecycle): api · iac · kubernetes · cicd-pipeline · race-condition -->
<!-- Accepted risks MUST be written here with the reason. -->

## Deploy / Migrations / Env · `OPS`
<!-- Migration steps, env vars, secrets, rollout/rollback notes. -->

### Agent execution safety gate
<!-- CONTEXT.md §11.7. Planning a command is not permission to execute it. Before EACH commit,
push, direct DB command, migration, seed, reset, import, or restore, record the exact target and ask
the user for explicit confirmation. Do not reuse approval from an earlier invocation. -->
