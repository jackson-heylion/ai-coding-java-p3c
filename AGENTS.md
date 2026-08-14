# Repository AI Instructions

## 1. Load minimally

For Java work, read only:

- `.ai/rules/core.md`
- `.agents/skills/java-development/SKILL.md` when implementation/review workflow is needed

Then load domain rules only when the change touches that area:

| Trigger | Rule |
|---|---|
| Spring/Spring Boot | `.ai/rules/spring-boot.md` |
| SQL/persistence/schema/transaction | `.ai/rules/database.md` |
| HTTP/RPC/DTO/serialization | `.ai/rules/api.md` |
| auth/input/secrets/tenant/sensitive data | `.ai/rules/security.md` |
| behavior/tests | `.ai/rules/testing.md` |
| explicit P3C mapping/history ambiguity | `.ai/rules/p3c.md` |

Do not preload every rule. For rare edge cases, search only the relevant heading in `docs/rules/deep-reference.md`.

## 2. Priority

1. Explicit task requirement
2. Security/correctness/data integrity/public contract
3. Existing repository architecture/conventions
4. Applicable domain rule
5. Core Java/P3C baseline

Java 17/21 standard syntax is first-class. Static analysis uses PMD 7 only; never downgrade source syntax or introduce legacy `p3c-pmd`/PMD 6.

## 3. Change discipline

- Inspect the nearest relevant implementation/tests first.
- Make the smallest coherent change.
- Reuse existing abstractions and vocabulary.
- Avoid unrelated cleanup/refactoring.
- Preserve compatibility unless breaking change is requested.

## 4. Verification budget

Do **not** run every check after every edit.

| Change | Minimum useful action |
|---|---|
| docs/comments/rules only | no Java build |
| compile/API-shape risk | `bash scripts/verify-java.sh compile` |
| behavior change | narrow test, then `bash scripts/verify-java.sh test` |
| static-rule feedback only | `bash scripts/verify-java.sh static` |
| normal final check | `bash scripts/verify-java.sh auto` |
| root build/cross-module/high-risk change | `bash scripts/verify-java.sh all` |

Use `MODULES=...` and `TEST=...` to narrow Maven scope when known. Never run `compile` before `test` just for completeness; Maven `test` already compiles. Never run normal `verify` and then another PMD `verify`; `all` performs a single lifecycle with PMD enabled.

Fix failures introduced by the current change; do not mass-fix unrelated legacy issues.