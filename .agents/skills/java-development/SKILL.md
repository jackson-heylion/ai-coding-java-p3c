---
name: java-development
description: Minimal workflow for Java 17/21 implementation, review, testing, and PMD 7 local validation.
---

# Java Development Skill

## Workflow

1. Read `AGENTS.md` and `.ai/rules/core.md`.
2. Inspect nearest similar code/tests.
3. Load only triggered domain rules.
4. Identify correctness constraints: contract, auth/data scope, transaction, idempotency/concurrency, nullability, compatibility.
5. Implement the smallest coherent change with repository conventions and Java 17/21 idioms.
6. Validate at the narrowest useful scope.
7. Review the final diff for accidental contract/security/data/concurrency changes.

## Rule routing

- Spring → `.ai/rules/spring-boot.md`
- persistence/SQL → `.ai/rules/database.md`
- HTTP/RPC → `.ai/rules/api.md`
- security/input/tenant/secrets → `.ai/rules/security.md`
- behavior/tests → `.ai/rules/testing.md`
- explicit P3C interpretation → `.ai/rules/p3c.md`

If a concise rule is insufficient, search the exact relevant heading in `docs/rules/deep-reference.md`; do not preload the whole reference.

## Native validation launcher

Choose the current platform:

```text
macOS/Linux       bash scripts/verify-java.sh <mode>
Windows CMD       scripts\verify-java.cmd <mode>
Windows PowerShell powershell -File scripts\verify-java.ps1 <mode>
```

Use one useful mode instead of a ritual sequence:

- `compile` — compile risk only
- `test` — behavior iteration; `TEST` may narrow further
- `static` — PMD only
- `auto` — change-aware final validation
- `all` — full reactor/high-risk validation

Rules:

- `test` already compiles; do not run `compile` first for completeness.
- `all` runs one lifecycle with PMD; do not run `verify` then another PMD `verify`.
- Use `MODULES` for known multi-module scope and `TEST` for focused tests.
- Docs/rules-only changes need no Java build.
- If Git change detection is unavailable, `auto` falls back to full reactor validation.
- Fix current-change failures, not unrelated legacy debt.

PMD 7 is the only static-analysis parser. Never rewrite valid Java 17/21 syntax for legacy tooling.