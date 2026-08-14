# AI Coding Java P3C

Repository-scoped Java coding standards for AI coding agents, based on the [Alibaba Java Coding Guidelines (P3C)](https://github.com/alibaba/p3c) and adapted for modern Java / Spring Boot projects.

The goal is not to paste the whole P3C handbook into an AI prompt. Instead, this repository separates standards into small, task-selectable rule files, an AI development workflow, and local deterministic verification.

```text
AI entry point          -> AGENTS.md
Task-specific rules     -> .ai/rules/*.md
AI development flow    -> .agents/skills/java-development/SKILL.md
Local verification     -> scripts/verify-java.sh + Maven + tests + optional P3C PMD
```

No GitHub Actions configuration is required by this template.

## Structure

```text
.
├── AGENTS.md
├── .ai/
│   └── rules/
│       ├── java.md
│       ├── spring-boot.md
│       ├── database.md
│       ├── api.md
│       ├── security.md
│       ├── testing.md
│       └── p3c.md
├── .agents/
│   └── skills/
│       └── java-development/
│           └── SKILL.md
├── config/
│   └── pmd/
│       └── p3c.xml
├── scripts/
│   └── verify-java.sh
├── docs/
│   └── local-verification.md
└── examples/
    ├── AGENTS.example.md
    └── maven/
        └── p3c-local-profile.xml
```

## Rule model

For every Java change, the baseline is:

- `.ai/rules/java.md`
- `.ai/rules/p3c.md`

Additional rules are loaded only when relevant:

| Task touches | Load |
|---|---|
| Spring / Spring Boot | `spring-boot.md` |
| SQL, ORM, schema, transactions | `database.md` |
| HTTP/RPC contracts, DTOs, serialization | `api.md` |
| Authentication, authorization, input, secrets | `security.md` |
| Tests or behavior changes | `testing.md` |

Example: an authenticated REST endpoint backed by a database normally loads all of these:

```text
java.md
p3c.md
spring-boot.md
api.md
security.md
database.md
testing.md
```

A pure Java calculation may need only:

```text
java.md
p3c.md
testing.md
```

This keeps the coding standard explicit without forcing every AI turn to consume every rule document.

## Rule priority

When rules conflict, use this order:

1. Explicit task requirements
2. Security, correctness, data integrity, and explicit public contracts
3. Existing repository architecture and local conventions
4. Applicable project/domain rules
5. Modern Java platform conventions
6. P3C baseline rules
7. General Java conventions

P3C is a baseline, not an architectural authority. In particular, this template does **not** require every `Service` or `DAO` to have a matching interface and `Impl` class.

## What each rule covers

- `java.md`: modern Java naming, null safety, exceptions, collections, concurrency, resources, logging, immutability, and JDK APIs.
- `spring-boot.md`: dependency injection, configuration, controllers, transactions, validation, async behavior, and Spring conventions.
- `database.md`: transactions, idempotency, concurrency, SQL safety, indexes, pagination, schema rollout, precision, time semantics, and persistence frameworks.
- `api.md`: DTOs, validation, HTTP/RPC semantics, errors, idempotency, pagination, serialization, compatibility, and object-level authorization.
- `security.md`: authentication, authorization, tenant/data scope, injection, secrets, tokens, uploads, SSRF, deserialization, sensitive data, and secure failure behavior.
- `testing.md`: regression tests, boundaries, determinism, isolation, Spring/database/API/security testing, concurrency, and idempotency.
- `p3c.md`: adapted Alibaba P3C baseline for AI coding.

## Use in an existing Maven project

Copy these into the project root:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
scripts/verify-java.sh
```

Then adapt the rule files to the project's actual architecture and stack.

For optional P3C PMD scanning, copy the profile from:

```text
examples/maven/p3c-local-profile.xml
```

into the project's `<profiles>` section in `pom.xml`.

## Local verification

The verification script prefers `./mvnw` and falls back to `mvn`.

### Fast feedback

```bash
bash scripts/verify-java.sh fast
```

Runs compile and tests.

### Normal completion check

```bash
bash scripts/verify-java.sh full
```

Runs the project's normal Maven `verify` lifecycle.

### Optional P3C scan

```bash
bash scripts/verify-java.sh p3c
```

Requires the `p3c-local` Maven profile.

### Combined local check

```bash
bash scripts/verify-java.sh all
```

Runs normal `verify`, then P3C when the profile is configured.

See `docs/local-verification.md` for the complete workflow.

## Maven / P3C PMD

Alibaba P3C provides PMD implementations through:

```text
com.alibaba.p3c:p3c-pmd:2.1.1
```

The upstream implementation uses an older PMD/JDK toolchain. Because modern Java 17/21 syntax may not always be compatible with that parser, this repository treats P3C PMD as an **optional local verified subset**, not as the sole definition of the coding standard.

The Maven profile example intentionally pins the legacy-compatible plugin combination and points it at:

```text
config/pmd/p3c.xml
```

The adapted ruleset excludes `ServiceOrDaoClassShouldEndWithImplRule` so projects are not forced to manufacture interface/implementation pairs solely for historical convention compliance.

If the legacy parser cannot understand valid modern Java code:

- keep enforcing `.ai/rules/p3c.md` at the AI/review layer;
- keep compile/tests/project `verify` as the primary local correctness gate;
- do not downgrade modern Java code merely to satisfy the old parser.

## AI agent behavior

`AGENTS.md` is the portable entry point. Agents that support repository instructions should read it directly. Agents with a skill mechanism can additionally use `.agents/skills/java-development/SKILL.md`.

The intended loop is:

```text
inspect existing code
       ↓
select applicable rules
       ↓
implement narrowly
       ↓
add/update relevant tests
       ↓
run local verification
       ↓
review final diff
```

## Principles

- Rules live in Git, not personal IDE settings.
- Load only rules relevant to the current task.
- AI writes compliant code from the start.
- Local build/tests/static analysis verify what can be checked mechanically.
- Existing code is not mass-refactored merely to satisfy a new baseline.
- Modern Java/Spring conventions override obsolete P3C recommendations.
- Security, integrity, correctness, and compatibility override style preferences.
- Every rule should be short, actionable, and reviewable.

## Upstream

This project is inspired by and references [alibaba/p3c](https://github.com/alibaba/p3c), licensed under Apache License 2.0. This repository is not an official Alibaba project.
