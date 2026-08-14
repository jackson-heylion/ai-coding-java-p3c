# AI Coding Java P3C

Repository-scoped Java coding standards for AI coding agents, based on the [Alibaba Java Coding Guidelines (P3C)](https://github.com/alibaba/p3c) and adapted for modern Java 17/21 + Spring Boot projects.

P3C is used as an **engineering guideline source**, not as a legacy parser/runtime dependency. Executable static analysis uses maintained **PMD 7** rules and parser infrastructure.

```text
AI entry point          -> AGENTS.md
Task-specific rules     -> .ai/rules/*.md
AI development flow    -> .agents/skills/java-development/SKILL.md
Local verification     -> scripts/verify-java.sh + Maven + tests + PMD 7
```

No GitHub Actions configuration is required by this template.

## Java baseline

Target projects:

- Java 17
- Java 21
- Spring Boot 3+
- Maven

Static-analysis baseline:

```text
maven-pmd-plugin 3.28.0
PMD runtime       7.26.0
```

There is **no runtime dependency on `com.alibaba.p3c:p3c-pmd` and no PMD 6 fallback**.

PMD 7 natively understands Java 21 standard language features, including record patterns and pattern matching for `switch`, while also supporting Java 17 source syntax.

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

Example: an authenticated REST endpoint backed by a database normally loads:

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
- `p3c.md`: adapted Alibaba P3C engineering baseline for AI coding.

## Modern PMD 7 ruleset

`config/pmd/p3c.xml` no longer references Alibaba PMD rule classes.

Its deterministic core is PMD's maintained Java quickstart ruleset, supplemented with production-safety rules aligned with this repository's P3C/security intent.

Examples of enforced areas include:

- naming conventions;
- control-statement braces;
- missing `@Override`;
- `equals`/`hashCode` correctness;
- null-check errors;
- resource closing;
- exception stack-trace preservation;
- unsafe collection operations;
- thread-safety problems;
- direct exposure/storage of mutable arrays;
- `printStackTrace()` usage;
- unsupported JDK-internal APIs;
- extending/overriding `Thread.run` instead of using task abstractions;
- hard-coded cryptographic keys/IVs.

The intent is **P3C semantics + maintained modern analyzer**, not a byte-for-byte port of Alibaba's historical PMD implementation.

## Java 17 / Java 21 syntax

The static-analysis path is expected to accept standard Java 17/21 syntax, including:

- records;
- sealed classes and interfaces;
- text blocks;
- switch expressions;
- pattern matching for `instanceof`;
- record patterns;
- pattern matching for `switch`;
- lambdas and method references;
- modern concurrency APIs including virtual-thread usage at source/type-analysis level.

The Maven compiler remains the authority for the project's configured Java release. PMD performs static analysis without forcing source code back to older Java syntax.

Preview features are intentionally separate from the Java 17/21 standard baseline and should be configured explicitly by projects that use them.

## Use in an existing Maven project

Copy these into the project root:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
scripts/verify-java.sh
```

Then copy:

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

### PMD 7 / P3C-aligned scan

```bash
bash scripts/verify-java.sh p3c
```

Runs PMD 7.26.0 against `config/pmd/p3c.xml` through the `p3c-local` Maven profile.

### Combined local check

```bash
bash scripts/verify-java.sh all
```

Runs normal `verify`, then PMD 7 static analysis.

See `docs/local-verification.md` for details.

## Why not Alibaba p3c-pmd?

The original P3C PMD implementation was built for an older PMD/JDK generation. Keeping that runtime would force modern Java projects to depend on a legacy parser/API layer.

This project deliberately separates:

```text
Alibaba P3C
    -> engineering intent / human + AI rules

PMD 7
    -> maintained Java parser / AST / type resolution / executable rules
```

That separation lets the coding standard retain useful P3C ideas without constraining Java 17/21 source code to historical parser capabilities.

## AI agent behavior

`AGENTS.md` is the portable entry point. Agents that support repository instructions should read it directly. Agents with a skill mechanism can additionally use `.agents/skills/java-development/SKILL.md`.

The intended loop is:

```text
inspect existing code
       ↓
select applicable rules
       ↓
implement with Java 17/21 idioms
       ↓
add/update relevant tests
       ↓
run local Maven verification
       ↓
run PMD 7 analysis
       ↓
review final diff
```

A parser error is a tooling failure and must not be "fixed" by downgrading valid Java 17/21 code to Java 8-era syntax.

## Principles

- Rules live in Git, not personal IDE settings.
- P3C provides engineering intent; PMD 7 provides deterministic analysis.
- No legacy Alibaba PMD runtime is required.
- Java 17/21 language features are first-class.
- Load only rules relevant to the current task.
- AI writes compliant code from the start.
- Local build/tests/static analysis verify what can be checked mechanically.
- Existing code is not mass-refactored merely to satisfy a new baseline.
- Modern Java/Spring conventions override obsolete P3C recommendations.
- Security, integrity, correctness, and compatibility override style preferences.

## Upstream

This project is inspired by and references [alibaba/p3c](https://github.com/alibaba/p3c), licensed under Apache License 2.0. This repository is not an official Alibaba project.
