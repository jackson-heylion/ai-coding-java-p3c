# AI Coding Java P3C

Repository-scoped Java coding standards for AI coding agents, based on the [Alibaba Java Coding Guidelines (P3C)](https://github.com/alibaba/p3c) and adapted for modern Java / Spring Boot projects.

The goal is not to paste the whole P3C handbook into an AI prompt. Instead, this repository separates standards into small, task-selectable rule files plus a development workflow and deterministic verification.

```text
AI entry point          -> AGENTS.md
Task-specific rules     -> .ai/rules/*.md
AI development flow    -> .agents/skills/java-development/SKILL.md
Deterministic checking -> config/pmd/p3c.xml + tests + Maven/CI
```

## Why

Large coding handbooks are poor system prompts: they consume context, mix obsolete and current advice, and cannot guarantee that generated code actually complies.

This repository therefore uses P3C as a baseline while giving modern Java, domain-specific engineering rules, repository conventions, correctness, security, and compatibility higher priority where appropriate.

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
└── examples/
    └── AGENTS.example.md
```

## Rule model

Two rules are the baseline for Java changes:

- `.ai/rules/java.md`
- `.ai/rules/p3c.md`

Additional rules are loaded by task type:

| Task touches | Load |
|---|---|
| Spring / Spring Boot | `spring-boot.md` |
| SQL, ORM, schema, transactions | `database.md` |
| HTTP/RPC contracts, DTOs, serialization | `api.md` |
| Authentication, authorization, input, secrets | `security.md` |
| Tests or behavior changes | `testing.md` |

A real feature commonly uses several rule files. For example:

```text
Authenticated REST endpoint with database access

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

This selective-loading model keeps rules explicit without forcing every AI coding turn to consume every document.

## Recommended rule priority

When rules conflict, use this order:

1. Explicit task requirements
2. Existing repository architecture and local conventions
3. Applicable project/domain rules
4. Modern Java platform conventions
5. P3C baseline rules
6. General Java conventions

Security, correctness, data integrity, and explicit API contracts are not style preferences and must not be weakened to satisfy a lower-priority style rule.

Some original P3C recommendations were written for older Java/Spring ecosystems. For example, this template does **not** require every `Service` or `DAO` class to have a matching interface and `Impl` class.

## What each rule covers

### `java.md`

Modern Java baseline: naming, null safety, exceptions, collections, concurrency, resources, logging, immutability, modern language/JDK APIs, and maintainable structure.

### `spring-boot.md`

Spring application conventions: dependency injection, bean boundaries, configuration, controllers, transactions, validation, logging, async behavior, and framework usage.

### `database.md`

Persistence correctness: transactions, idempotency, concurrency, SQL safety, indexes, pagination, schema rollout, precision, time semantics, MyBatis/MyBatis-Plus/JPA concerns, and bounded data operations.

### `api.md`

Contract design: request/response DTOs, validation, HTTP semantics, stable errors, idempotency, pagination, filtering/sorting, serialization, RPC semantics, compatibility, and object-level authorization.

### `security.md`

Secure coding baseline: authentication, authorization, tenant/data scope, input validation, injection, secrets, tokens, cryptography, uploads, SSRF, deserialization, sensitive data, Spring Security, and safe failure behavior.

### `testing.md`

Behavior-oriented testing: regression tests, boundaries, determinism, isolation, test scope, Spring/database/API/security testing, concurrency/idempotency tests, test data, and meaningful coverage.

### `p3c.md`

Adapted Alibaba P3C baseline. It keeps useful mandatory engineering rules while explicitly allowing modern Java/Spring conventions to override outdated architectural prescriptions.

## Use in an existing project

Copy the following directories/files into the project root:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
```

Then adapt the domain rules to the project's actual architecture and stack.

The important pattern is:

```text
AGENTS.md
    -> routes the agent to applicable rules
.ai/rules/
    -> contains detailed, reviewable coding rules
.agents/skills/
    -> defines implementation/review workflow
PMD + tests + build
    -> verifies what can be checked deterministically
```

## Maven / P3C PMD

Alibaba P3C provides PMD implementations in `com.alibaba.p3c:p3c-pmd:2.1.1`. The upstream implementation is based on an older PMD/Java toolchain, so test compatibility before making it a hard gate for Java 17/21 syntax.

A representative Maven configuration is:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-pmd-plugin</artifactId>
    <configuration>
        <rulesets>
            <ruleset>${project.basedir}/config/pmd/p3c.xml</ruleset>
        </rulesets>
        <printFailingErrors>true</printFailingErrors>
    </configuration>
    <executions>
        <execution>
            <phase>verify</phase>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.p3c</groupId>
            <artifactId>p3c-pmd</artifactId>
            <version>2.1.1</version>
        </dependency>
    </dependencies>
</plugin>
```

For newer Java projects, use P3C PMD as a verified subset rather than assuming every upstream rule is still architecturally desirable.

## AI agent compatibility

`AGENTS.md` is the portable entry point. Tools that support repository instructions can read it directly. Tools with a skill mechanism can additionally use `.agents/skills/java-development/SKILL.md`.

The rule files themselves are tool-neutral and remain versioned with the codebase. This allows different coding agents to share one engineering standard instead of maintaining separate prompts per tool.

## Principles

- Rules live in Git, not in personal IDE settings.
- Load only rules relevant to the current task.
- AI writes compliant code from the start instead of fixing style afterward.
- Static analysis validates rules that can be checked mechanically.
- Tests validate behavior and important invariants.
- Existing code is not mass-refactored merely to satisfy a new baseline.
- Modern Java/Spring conventions override obsolete P3C recommendations.
- Security, integrity, and compatibility override style preferences.
- Every rule should be short, actionable, and reviewable.

## Upstream

This project is inspired by and references [alibaba/p3c](https://github.com/alibaba/p3c), licensed under Apache License 2.0. This repository is not an official Alibaba project.
