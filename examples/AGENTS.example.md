# Project AI Instructions

This is an example of how a real Java/Spring Boot Maven project can consume the rules from `ai-coding-java-p3c`.

## Project baseline

- Java: 17 or 21
- Spring Boot: 3+
- Build: Maven
- Verification: local only
- Static analysis: PMD 7 (no Alibaba p3c-pmd runtime)

## Coding standards

For every Java change, read:

1. `.ai/rules/java.md`
2. `.ai/rules/p3c.md`

Then load rules based on the task:

| Change area | Rule |
|---|---|
| Spring / Spring Boot | `.ai/rules/spring-boot.md` |
| SQL / persistence / schema / transaction | `.ai/rules/database.md` |
| HTTP / RPC / DTO / API contract | `.ai/rules/api.md` |
| authentication / authorization / secrets / untrusted input | `.ai/rules/security.md` |
| tests or behavior changes | `.ai/rules/testing.md` |

Multiple rules may apply to one change. Do not load unrelated domain rules automatically.

For Java implementation/review workflow, follow:

- `.agents/skills/java-development/SKILL.md`

## Java 17/21 policy

Modern standard Java syntax is allowed and should not be downgraded for tooling compatibility.

Examples include:

- records and sealed types;
- switch expressions;
- pattern matching for `instanceof`;
- Java 21 record patterns and pattern matching for `switch`;
- deliberate use of Java 21 virtual-thread APIs.

Use PMD 7 for static analysis. Do not add PMD 6 or `com.alibaba.p3c:p3c-pmd` as a fallback.

## Project-specific rules

Add project rules here. Examples:

- Use the existing package/module architecture.
- Use MyBatis-Plus in modules that already use MyBatis-Plus; do not introduce JPA there.
- Use constructor injection.
- REST APIs return project-standard response/error structures.
- Transaction boundaries belong in the application/service layer.
- Use existing domain enums/constants rather than creating duplicate values.
- Follow the repository's logging and trace-id conventions.
- Derive tenant/user identity from authenticated context rather than trusting request fields.
- Preserve existing API and database compatibility unless the task explicitly allows a breaking change.

## Priority

When rules conflict:

1. explicit task requirement;
2. security, correctness, data integrity, and explicit public contracts;
3. existing project architecture/conventions;
4. this project's rules;
5. applicable `.ai/rules/*.md` domain rules;
6. `.ai/rules/java.md`;
7. `.ai/rules/p3c.md`.

P3C is a baseline, not permission to rewrite established project architecture.

## Before implementation

- Inspect nearby implementation and tests.
- Identify applicable domain rules.
- Identify transaction, authorization/data-scope, compatibility, concurrency/idempotency, and test constraints relevant to the change.
- Reuse existing repository patterns.

## Local verification

Install the `p3c-local` profile from `examples/maven/p3c-local-profile.xml`, then use:

```bash
# fast development feedback
bash scripts/verify-java.sh fast

# normal Maven completion check
bash scripts/verify-java.sh full

# PMD 7 / P3C-aligned static analysis
bash scripts/verify-java.sh p3c

# final combined local verification
bash scripts/verify-java.sh all
```

`all` must not silently skip PMD. Missing `p3c-local` configuration is a local-tooling error.

If the script is unavailable, run the repository's Maven wrapper or Maven directly and explicitly execute the PMD 7 profile.

Run narrow relevant tests first when useful. Add regression/behavior tests when behavior changes and practical.

Fix compilation, test, security, integrity, compatibility, PMD parser, and static-analysis failures caused by the current change. Do not mass-fix unrelated historical violations unless explicitly requested.
