# Repository AI Instructions

## 1. Load minimally

For Java work, read only `.ai/rules/core.md`. Load `.agents/skills/java-development/SKILL.md` when workflow guidance is needed.

Load domain rules only when triggered:

| Trigger | Rule |
|---|---|
| Spring/Spring Boot | `.ai/rules/spring-boot.md` |
| SQL/persistence/schema/transaction | `.ai/rules/database.md` |
| HTTP/RPC/DTO/serialization | `.ai/rules/api.md` |
| auth/input/secrets/tenant/sensitive data | `.ai/rules/security.md` |
| behavior/tests | `.ai/rules/testing.md` |
| explicit P3C mapping/history ambiguity | `.ai/rules/p3c.md` |

For rare edge cases, search only the relevant heading in `docs/rules/deep-reference.md`.

## 2. Priority

1. Explicit task requirement
2. Security/correctness/data integrity/public contract
3. Existing repository architecture/conventions
4. Applicable domain rule
5. Core Java/P3C baseline

Java 17/21 standard syntax is first-class. Static analysis uses PMD 7 only.

## 3. Change discipline

- Inspect nearest relevant code/tests first.
- Make the smallest coherent change.
- Reuse existing patterns; avoid unrelated cleanup.
- Preserve compatibility unless a breaking change is requested.

## 4. Native verification launcher

Use the current OS; do not require Bash on Windows or PowerShell on Unix:

- macOS/Linux: `bash scripts/verify-java.sh <mode>`
- Windows CMD: `scripts\verify-java.cmd <mode>`
- Windows PowerShell: `powershell -File scripts\verify-java.ps1 <mode>`

Modes are identical on all platforms.

## 5. Verification budget

| Change | Minimum useful mode |
|---|---|
| docs/comments/rules only | none |
| compile/API-shape risk | `compile` |
| behavior change | narrow test, then `test` |
| static-rule feedback only | `static` |
| normal final check | `auto` |
| root build/cross-module/high-risk | `all` |

Use `MODULES` and `TEST` environment variables to narrow scope when known. `test` already compiles. `all` performs one Maven lifecycle with PMD enabled; do not run redundant `verify`/PMD sequences.

If Git change detection is unavailable, `auto` must fall back to the full Maven reactor rather than skip validation.

Fix current-change failures; do not mass-fix unrelated legacy issues.