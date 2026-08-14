---
name: java-development
description: Implement, refactor, or review Java code using repository conventions, modern Java/Spring Boot practices, and the adapted Alibaba P3C baseline.
---

# Java Development Skill

Use this skill for Java implementation, refactoring, bug fixing, and code review.

## Required rules

Before editing Java code, read:

1. `AGENTS.md`
2. `.ai/rules/java.md`
3. `.ai/rules/spring-boot.md` when Spring/Spring Boot is involved
4. `.ai/rules/p3c.md`

Treat repository-local architecture and explicit task requirements as higher priority than generic P3C guidance.

## Workflow

### 1. Inspect before editing

Inspect the smallest useful set of nearby files to understand:

- package/module boundaries;
- similar implementations;
- public contracts;
- persistence style;
- error handling;
- transaction boundaries;
- test conventions;
- existing utilities/abstractions.

Do not invent a new pattern before checking whether the repository already has one.

### 2. Identify correctness constraints

Before implementation, identify applicable constraints such as:

- nullability;
- authorization/tenant scope;
- idempotency;
- transaction boundaries;
- concurrency;
- ordering/uniqueness;
- retry semantics;
- backward compatibility;
- data migration/serialization compatibility.

### 3. Implement narrowly

While editing:

- make the smallest coherent change that solves the task;
- preserve public behavior not targeted by the task;
- follow Java/Spring/P3C rules while writing;
- avoid speculative abstractions;
- avoid unrelated formatting/refactoring;
- reuse existing domain vocabulary and utilities.

Do not create `Service`/`ServiceImpl` or `DAO`/`DAOImpl` pairs solely to satisfy historical P3C conventions.

### 4. Test behavior

Add/update tests when behavior changes and a relevant testing pattern exists.

Prefer the narrowest useful test scope:

1. unit test;
2. layer/slice test;
3. integration test;
4. full application test only when necessary.

Test behavior and important edge cases rather than implementation details.

### 5. Validate

Run repository-provided commands when available. For Maven projects, typical checks are:

```bash
mvn -q -DskipTests compile
mvn -q test
mvn -q verify
```

If working in one module, run the narrowest module command first.

When P3C PMD is enabled, fix violations introduced by the current change. Do not broaden scope into mass cleanup of historical violations unless requested.

### 6. Review the diff

Before finishing, review the final diff for:

- accidental API changes;
- missing null/error handling;
- transaction/concurrency mistakes;
- unsafe SQL/input handling;
- sensitive logging;
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
6. maintainability;
7. P3C/style.

For each meaningful finding, state:

- what is wrong;
- why it matters;
- the triggering condition;
- a concrete fix direction.

Do not inflate the review with cosmetic findings that formatters/static analysis can handle automatically.
