# Core Java Rules

Load this file for every Java change. Do not load other rule files unless the task triggers them.

## MUST

- Follow explicit task requirements and nearby repository conventions before generic rules.
- Target the repository's configured Java version; Java 17/21 syntax is first-class. Never downgrade valid syntax for tooling.
- Keep changes scoped; avoid speculative abstractions and unrelated cleanup.
- Use meaningful names; classes `UpperCamelCase`, members `lowerCamelCase`, constants `UPPER_SNAKE_CASE`.
- Handle nullable/external values deliberately; use semantic equality for objects and correct `equals`/`hashCode` pairs.
- Avoid unexplained business magic values, swallowed exceptions, `return` in `finally`, unsafe resource handling, and sensitive logging.
- Use braces for control flow and modern JDK APIs (`java.time`, try-with-resources, records/pattern matching when appropriate).
- Do not create `Service`/`ServiceImpl` or DAO interface pairs solely for historical P3C ceremony.
- Preserve public/API/data compatibility unless a breaking change is explicitly requested.
- Security, correctness, data integrity, transaction safety, and authorization override style preferences.
- Static analysis uses PMD 7 only; never add Alibaba `p3c-pmd`, PMD 6, or another legacy parser.

## Load more only when needed

| Trigger | Load |
|---|---|
| Spring/Spring Boot | `spring-boot.md` |
| SQL/persistence/schema/transaction | `database.md` |
| HTTP/RPC/DTO/serialization | `api.md` |
| auth/input/secrets/tenant/sensitive data | `security.md` |
| behavior change/tests | `testing.md` |
| `pom.xml`/dependency/plugin/BOM/version | `maven.md` |
| Java language/library/numeric/concurrency edge case | `java.md` |
| P3C mapping/history or rule ambiguity | `p3c.md` |

For uncommon edge cases, search the relevant heading in `docs/rules/deep-reference.md`; do **not** read that file wholesale unless the task requires broad review.