# Project AI Instructions

This is an example of how a real Java/Spring Boot project can consume the rules from `ai-coding-java-p3c`.

## Project baseline

- Java: 17+
- Spring Boot: 3+
- Build: Maven

## Coding standards

All Java code created or modified by an AI agent MUST follow the repository's copied rule files:

1. `.ai/rules/java.md`
2. `.ai/rules/spring-boot.md`
3. `.ai/rules/p3c.md`

For Java implementation/review workflow, follow:

- `.agents/skills/java-development/SKILL.md`

## Project-specific rules

Add project rules here. Examples:

- Use the existing package/module architecture.
- Use MyBatis-Plus in modules that already use MyBatis-Plus; do not introduce JPA there.
- Use constructor injection.
- REST APIs return project-standard response/error structures.
- Transaction boundaries belong in the application/service layer.
- Use existing domain enums/constants rather than creating duplicate values.
- Follow the repository's logging and trace-id conventions.

## Priority

When rules conflict:

1. explicit task requirement;
2. existing project architecture/conventions;
3. this project's rules;
4. `.ai/rules/java.md`;
5. `.ai/rules/spring-boot.md`;
6. `.ai/rules/p3c.md`.

P3C is a baseline, not permission to rewrite established project architecture.

## Verification

For Java changes, run the relevant project commands. Typical Maven flow:

```bash
mvn -q -DskipTests compile
mvn -q test
mvn -q verify
```

Fix compilation, test, and static-analysis failures caused by the current change.
Do not mass-fix unrelated historical violations unless explicitly requested.
