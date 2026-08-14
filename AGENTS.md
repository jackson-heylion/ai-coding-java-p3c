# Repository AI Instructions

These instructions apply to all AI coding work in this repository and to projects that copy this template.

## Rule sources

For Java work, always read and follow:

1. `.ai/rules/java.md`
2. `.ai/rules/p3c.md`

Load additional rules only when the task touches that area:

| Area | Rule file |
|---|---|
| Spring / Spring Boot | `.ai/rules/spring-boot.md` |
| SQL, ORM, persistence, schema, transactions | `.ai/rules/database.md` |
| HTTP/RPC contracts, DTOs, serialization | `.ai/rules/api.md` |
| Auth, permissions, input, secrets, sensitive data | `.ai/rules/security.md` |
| Tests or behavior changes requiring tests | `.ai/rules/testing.md` |

A change may require several domain rules. For example, a new authenticated REST endpoint backed by a database typically requires `spring-boot.md`, `api.md`, `security.md`, `database.md`, and `testing.md` in addition to the Java/P3C baseline.

For implementation and review workflow, follow:

- `.agents/skills/java-development/SKILL.md`

## Java platform baseline

This template treats Java 17 and Java 21 as first-class targets.

Do not rewrite valid modern Java merely to satisfy obsolete tooling. Standard Java 17/21 language features are allowed when appropriate, including records, sealed types, switch expressions, pattern matching, record patterns, and Java 21 virtual-thread APIs.

Executable static analysis uses PMD 7. The repository must not introduce `com.alibaba.p3c:p3c-pmd`, PMD 6, or another legacy Java parser as a fallback.

P3C provides engineering intent; PMD 7 provides maintained deterministic analysis.

## Priority

When instructions conflict, use this order:

1. Explicit task requirements
2. Existing repository architecture and established local conventions
3. Applicable project/domain rules in `.ai/rules/`
4. `.ai/rules/java.md`
5. `.ai/rules/p3c.md`
6. General Java conventions

Security, correctness, data integrity, and explicit public contracts are not style preferences and must not be weakened to satisfy a lower-priority style rule.

Do not apply P3C mechanically when an older recommendation conflicts with modern Java, Spring Boot, or the existing repository architecture.

## Before changing code

- Inspect nearby code and tests before implementing.
- Identify module boundaries, naming conventions, public contracts, persistence pattern, error model, transaction boundaries, security/data scope, and test style relevant to the task.
- Determine which `.ai/rules/*.md` files apply before editing.
- Reuse existing abstractions instead of introducing parallel ones.
- Keep the change scoped to the requested task.

## While changing Java code

- Follow all applicable MUST rules.
- Prefer simple, explicit code over speculative abstractions.
- Do not add an interface solely so an implementation can be named `*Impl`.
- Do not introduce deprecated APIs, unsafe concurrency, hidden null assumptions, unexplained magic values, insecure defaults, or unbounded data operations.
- Preserve backward compatibility unless the task explicitly allows breaking changes.
- Avoid unrelated formatting or cleanup churn.
- Prefer appropriate Java 17/21 APIs and language constructs over Java 8-era boilerplate.

## Local verification

Verification is local. Do not depend on GitHub Actions or another CI service to complete a coding task.

When `scripts/verify-java.sh` exists, use it:

```bash
# Fast feedback during implementation
bash scripts/verify-java.sh fast

# Normal Maven lifecycle verification
bash scripts/verify-java.sh full

# PMD 7 / P3C-aligned static analysis
bash scripts/verify-java.sh p3c

# Required final local verification when p3c-local is installed
bash scripts/verify-java.sh all
```

`all` must not silently skip static analysis. If the `p3c-local` Maven profile is missing, treat that as local-tooling misconfiguration and report it.

The PMD profile must use the maintained PMD 7 runtime defined by this template. A PMD parser error is a tooling failure to investigate, not a reason to downgrade valid Java 17/21 source syntax.

If the script is not present, use the repository's Maven wrapper or Maven commands directly and run the configured PMD 7 profile explicitly.

Run the narrowest relevant test first when that gives faster feedback. If working in one module, module-specific checks may be run before root-level verification.

For behavior changes, use `.ai/rules/testing.md` to determine the appropriate regression/unit/integration coverage.

A task is not complete when the current change introduces:

- compilation failures;
- failing relevant tests;
- PMD parser/static-analysis errors;
- newly introduced static-analysis violations;
- security or authorization regressions;
- data-integrity/transaction regressions;
- accidental API compatibility breaks;
- obvious violations of the applicable rules above.

Fix violations caused by the current change. Do not mass-refactor unrelated legacy code merely to make the whole repository conform to a newly added rule.

## Review behavior

When reviewing code, prioritize findings in this order:

1. correctness and data integrity;
2. security and authorization;
3. concurrency and transaction safety;
4. API/contract compatibility;
5. performance/resource risks;
6. test gaps that can hide meaningful regressions;
7. maintainability and P3C/style issues.

Report concrete issues with file/line context, triggering conditions, impact, and a suggested correction. Avoid style-only comments when an automatic formatter or linter can resolve them.
