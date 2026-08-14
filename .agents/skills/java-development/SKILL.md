---
name: java-development
description: Implement, refactor, or review Java 17/21 code using repository conventions, modern Java/Spring Boot practices, domain-specific rules, the adapted Alibaba P3C baseline, and PMD 7 local verification.
---

# Java Development Skill

Use this skill for Java implementation, refactoring, bug fixing, and code review.

## Required rules

Before editing Java code, always read:

1. `AGENTS.md`
2. `.ai/rules/java.md`
3. `.ai/rules/p3c.md`

Then load only the domain rules relevant to the change:

- Spring/Spring Boot: `.ai/rules/spring-boot.md`
- persistence/SQL/schema/transactions: `.ai/rules/database.md`
- HTTP/RPC/API contracts: `.ai/rules/api.md`
- authentication/authorization/secrets/untrusted input: `.ai/rules/security.md`
- tests or behavior changes requiring tests: `.ai/rules/testing.md`

Treat repository-local architecture and explicit task requirements as higher priority than generic P3C guidance. Security, correctness, integrity, and explicit compatibility requirements must not be weakened for style consistency.

## Java platform

Java 17 and Java 21 are first-class targets.

Use modern language/API features when they make the implementation safer or clearer. Do not downgrade records, sealed types, switch expressions, pattern matching, record patterns, or deliberate Java 21 concurrency APIs to older syntax merely for tooling compatibility.

The executable analyzer is PMD 7. Do not introduce Alibaba `p3c-pmd`, PMD 6, or another legacy parser as a fallback.

## Workflow

### 1. Inspect before editing

Inspect the smallest useful set of nearby files to understand:

- package/module boundaries;
- similar implementations;
- public contracts;
- persistence style;
- error handling;
- transaction boundaries;
- authentication/authorization/data scope;
- test conventions;
- existing utilities/abstractions.

Do not invent a new pattern before checking whether the repository already has one.

### 2. Select applicable rules

Classify the change before implementation.

Examples:

- pure domain calculation -> Java + P3C + testing;
- repository query -> Java + P3C + database + testing;
- REST endpoint -> Java + P3C + Spring + API + testing;
- authenticated database-backed REST endpoint -> Java + P3C + Spring + API + security + database + testing.

Do not load unrelated rule files merely because they exist.

### 3. Identify correctness constraints

Before implementation, identify applicable constraints such as:

- nullability;
- authorization/tenant scope;
- idempotency;
- transaction boundaries;
- concurrency;
- ordering/uniqueness;
- retry semantics;
- backward compatibility;
- data migration/serialization compatibility;
- sensitive-data handling.

### 4. Implement narrowly

While editing:

- make the smallest coherent change that solves the task;
- preserve public behavior not targeted by the task;
- follow all applicable rules while writing;
- use appropriate Java 17/21 idioms;
- avoid speculative abstractions;
- avoid unrelated formatting/refactoring;
- reuse existing domain vocabulary and utilities.

Do not create `Service`/`ServiceImpl` or `DAO`/`DAOImpl` pairs solely to satisfy historical P3C conventions.

### 5. Test behavior

When behavior changes, consult `.ai/rules/testing.md` and add/update tests where practical.

Prefer the narrowest useful test scope:

1. unit test;
2. layer/slice test;
3. integration test;
4. full application/end-to-end test only when necessary.

Test behavior and important invariants rather than implementation details.

### 6. Validate locally

Do not rely on CI to validate the change.

When `scripts/verify-java.sh` exists, use it:

```bash
# During implementation
bash scripts/verify-java.sh fast

# Normal Maven lifecycle
bash scripts/verify-java.sh full

# PMD 7 / P3C-aligned static analysis
bash scripts/verify-java.sh p3c

# Final combined local verification
bash scripts/verify-java.sh all
```

`all` requires the `p3c-local` profile. Missing static-analysis configuration is a tooling problem, not a reason to silently skip analysis.

The script detects Java 17/21 from Maven compiler properties and passes the language level to PMD when possible.

If the script is unavailable, use the Maven wrapper/project commands and explicitly run the configured PMD 7 profile.

If working in one module, run narrow module tests first for feedback, then perform the appropriate root-level local verification before finishing.

Fix failures and static-analysis violations introduced by the current change. Do not broaden scope into mass cleanup of historical violations unless requested.

A PMD parser error must be investigated as a tooling failure. Never rewrite valid Java 17/21 syntax into Java 8-era code to accommodate obsolete tooling.

### 7. Review the diff

Before finishing, review the final diff for:

- accidental API changes;
- missing null/error handling;
- transaction/concurrency mistakes;
- authorization or tenant-scope bypass;
- unsafe SQL/input handling;
- sensitive logging;
- missing regression tests;
- dead code/imports;
- inconsistent naming;
- unnecessary abstractions;
- unrelated edits.

## Code review mode

When the task is a review, prioritize findings:

1. correctness/data loss;
2. security/authorization;
3. concurrency/transaction safety;
4. compatibility/contracts;
5. performance/resource risks;
6. meaningful test gaps;
7. maintainability;
8. P3C/style.

For each meaningful finding, state:

- what is wrong;
- why it matters;
- the triggering condition;
- a concrete fix direction.

Do not inflate the review with cosmetic findings that formatters/static analysis can handle automatically.
