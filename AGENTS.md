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

## Local verification

Verification is local. Do not depend on GitHub Actions or another CI service to complete a coding task.

When `scripts/verify-java.sh` exists, prefer it over inventing new project-wide commands:

```bash
# Fast feedback during implementation
bash scripts/verify-java.sh fast

# Normal completion check
bash scripts/verify-java.sh full

# Optional adapted P3C PMD scan, when p3c-local is configured
bash scripts/verify-java.sh p3c

# Normal verify + P3C when available
bash scripts/verify-java.sh all
```

If the script is not present, use the repository's Maven wrapper or Maven commands directly:

```bash
./mvnw -q verify
# or
mvn -q verify
```

Run the narrowest relevant test first when that gives faster feedback. If working in one module, module-specific checks may be run before root-level verification.

For behavior changes, use `.ai/rules/testing.md` to determine the appropriate regression/unit/integration coverage.

The `p3c-local` profile is optional because Alibaba P3C-PMD 2.1.1 uses an older PMD/JDK toolchain. Do not downgrade valid modern Java code merely to satisfy limitations of the legacy parser.

A task is not complete when the current change introduces:

- compilation failures;
- failing relevant tests;
- newly introduced static-analysis violations in configured local tooling;
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
