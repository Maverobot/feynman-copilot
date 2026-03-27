---
name: paper-code-audit
description: Compare a paper's claims against its public codebase. Use when the user asks to audit a paper, check code-claim consistency, verify reproducibility of a specific paper, or find mismatches between a paper and its implementation.
---

# Paper-Code Audit

Audit the paper and codebase for the given target.

Derive a short slug from the audit target (lowercase, hyphens, ≤5 words). Use this slug for all files.

## Workflow

1. **Plan** — Outline the audit: which paper, which repo, which claims to check. Write to `outputs/.plans/<slug>.md`. Present to user and confirm.

2. **Gather** — Use the researcher subagent for evidence gathering. Read the paper (via `alpha get` or `alpha ask`), inspect the codebase (via `alpha code` or direct repo access), and document findings.

3. **Compare** — Check claimed methods, defaults, metrics, and data handling against the actual code. Call out:
   - Missing code for described methods
   - Mismatches between paper and implementation
   - Ambiguous defaults or hyperparameters
   - Reproduction risks (undocumented dependencies, hardware assumptions)

4. **Cite** — Use the verifier subagent to verify sources and add inline citations when the audit is non-trivial.

5. **Deliver** — Save exactly one audit artifact to `outputs/<slug>-audit.md`. End with a Sources section containing paper and repository URLs.
