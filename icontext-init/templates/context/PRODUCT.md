# {{PROJECT_NAME}} — PRODUCT.md (Layer 2 · product & direction)

> **Split out of `CONTEXT.md`.** Holds §1 · §2 · §13. Section numbers are unchanged, so every
> existing `§N` reference in plans and docs still resolves — only the file moved.
> Siblings: [CONTEXT.md](../CONTEXT.md) (context map + workflow) · [DEV.md](./DEV.md) (development) · [DESIGN.md](./DESIGN.md) ·
> [SECURITY.md](./SECURITY.md) · [SKILLS.md](./SKILLS.md) · [PLAN.md](../PLAN.md) · [ROLE.md](./ROLE.md)

**Owners:** `STK BU PO` · **Read by:** everyone, before writing any plan.

---

### 1. ภาพรวมผลิตภัณฑ์ · Product Overview
- **What:** {{PROJECT_DESC}}
- **Platforms:** {{PLATFORMS}}
- **Reference:** {{REFERENCE}}
- **Status:** scaffolded — features not yet implemented
<!-- TODO: target users, value proposition -->

**Target users / personas**
<!-- TODO: who uses this, what job they're hiring it for. Keep in sync with ROLE.md personas. -->
| Persona | Job to be done | Pain today | Success looks like |
|---------|----------------|------------|--------------------|
| <!-- e.g. Ops admin --> | <!-- ... --> | <!-- ... --> | <!-- ... --> |

**Value proposition**
<!-- TODO: one sentence — for <user>, who <need>, this is a <category> that <key benefit>,
     unlike <alternative>. -->

**Success metrics**
<!-- TODO: how we know it worked (activation, retention, throughput, error rate…). Numbers, not adjectives. -->

**Non-goals**
<!-- TODO: what this product deliberately does NOT do. Prevents scope creep at plan time. -->

### 2. Key Decisions
<!-- Log decisions: date · decision · why · alternatives rejected.
     Product/direction decisions live here. Deep technical ADRs go in `docs/adr/` and are linked
     from this table. Never delete a row — supersede it with a newer one. -->

| Date | Decision | Why | Alternatives rejected | Status |
|------|----------|-----|-----------------------|--------|
| {{DATE}} | Stack chosen: web {{WEB_STACK}}, mobile {{MOBILE_STACK}}, api {{API_STACK}}, db {{DB_STACK}} | <!-- ... --> | <!-- ... --> | active |

### 13. Open Questions
<!-- Collect unknowns here. Each row should name an owner and what would unblock it, otherwise it
     rots. Move resolved questions into §2 as a decision. -->

| # | Question | Blocks | Owner | Needed by |
|---|----------|--------|-------|-----------|
| Q1 | <!-- TODO --> | <!-- plan / feature --> | <!-- PO --> | <!-- date --> |

---

## Keeping this in sync
- A change in product direction ⇒ update §1/§2 here **in the same change** as the affected plan
  (`plans/NNN-*/bu.md` §0–1, `po.md` §2–3).
- Plans reference this file, not a copy of it. Never duplicate the product overview into a plan.
- Second-brain rule (CONTEXT.md §11): record the **reasoning**, not only the outcome.
