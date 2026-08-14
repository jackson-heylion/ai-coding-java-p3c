---
name: java-development
description: Minimal workflow for Java 17/21 implementation, review, testing, and PMD 7 local validation.
---

# Java Development Skill

## Workflow

1. Read `AGENTS.md` and `.ai/rules/core.md`.
2. Inspect the nearest similar code/tests.
3. Load only triggered domain rules; do not preload all rules.
4. Identify only constraints that can change correctness: contract, auth/data scope, transaction, idempotency/concurrency, nullability, compatibility.
5. Implement the smallest coherent change with repository conventions and Java 17/21 idioms.
6. Test/validate at the narrowest useful scope.
7. Review the final diff for accidental contract/security/data/concurrency changes.

## Rule routing

- Spring → `.ai/rules/spring-boot.md`
- persistence/SQL → `.ai/rules/database.md`
- HTTP/RPC → `.ai/rules/api.md`
- security/input/tenant/secrets → `.ai/rules/security.md`
- behavior/tests → `.ai/rules/testing.md`
- explicit P3C interpretation → `.ai/rules/p3c.md`

If a concise rule is insufficient, search the exact relevant heading in `docs/rules/deep-reference.md`. Do not read the whole reference by default.

## Validation strategy

Prefer one useful command over a ritual sequence:

```bash
# syntax/compile risk only
bash scripts/verify-java.sh compile

# behavior work; TEST=... may narrow further
bash scripts/verify-java.sh test

# PMD feedback only; no test/verify lifecycle
bash scripts/verify-java.sh static

# change-aware final validation
bash scripts/verify-java.sh auto

# explicit full reactor/risky validation
bash scripts/verify-java.sh all
```

Rules:

- Do not run `compile` before `test`; `test` already compiles.
- Do not run `verify` then a second PMD `verify`; `all` runs one lifecycle with PMD enabled.
- Prefer `MODULES=module-a,module-b` for known multi-module scope.
- Prefer `TEST=ClassName` for a focused test during iteration.
- Documentation/rule-only changes need no Java build.
- Fix current-change failures; do not clean unrelated legacy violations.

PMD 7 is the only static-analysis parser. Never rewrite valid Java 17/21 syntax for legacy tooling.