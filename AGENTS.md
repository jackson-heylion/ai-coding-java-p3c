# Repository AI Instructions

These instructions apply to all AI coding work in this repository and to projects that copy this template.

## Rule sources

For Java work, read and follow:

1. `.ai/rules/java.md`
2. `.ai/rules/spring-boot.md` when Spring/Spring Boot is involved
3. `.ai/rules/p3c.md`

For implementation and review workflow, follow:

- `.agents/skills/java-development/SKILL.md`

## Priority

When instructions conflict, use this order:

1. Explicit task requirements
2. Existing repository architecture and established local conventions
3. `.ai/rules/java.md`
4. `.ai/rules/spring-boot.md`
5. `.ai/rules/p3c.md`
6. General Java conventions

Do not apply P3C mechanically when an older recommendation conflicts with modern Java, Spring Boot, or the existing repository architecture.

## Before changing code

- Inspect nearby code and tests before implementing.
- Identify the module boundaries, naming conventions, error model, persistence pattern, and test style already in use.
- Reuse existing abstractions instead of introducing parallel ones.
- Keep the change scoped to the requested task.

## While changing Java code

- Follow the MUST rules in `.ai/rules/*.md`.
- Prefer simple, explicit code over speculative abstractions.
- Do not add an interface solely so an implementation can be named `*Impl`.
- Do not introduce deprecated APIs, unsafe concurrency, hidden null assumptions, or unexplained magic values.
- Preserve backward compatibility unless the task explicitly allows breaking changes.
- Avoid unrelated formatting or cleanup churn.

## Verification

After modifying Java code, run the narrowest relevant validation first, then the normal project verification when practical.

Typical Maven commands:

```bash
mvn -q -DskipTests compile
mvn -q test
mvn -q verify
```

If the repository has wrapper scripts or module-specific commands, prefer those.

A task is not complete when the current change introduces:

- compilation failures;
- failing relevant tests;
- newly introduced static-analysis violations;
- obvious violations of the rules referenced above.

Fix violations caused by the current change. Do not mass-refactor unrelated legacy code merely to make the whole repository conform to a newly added rule.

## Review behavior

When reviewing code, prioritize findings in this order:

1. correctness and data integrity;
2. security and authorization;
3. concurrency and transaction safety;
4. API/contract compatibility;
5. performance risks;
6. maintainability and P3C/style issues.

Report concrete issues with file/line context and a suggested correction. Avoid style-only comments when an automatic formatter or linter can resolve them.
