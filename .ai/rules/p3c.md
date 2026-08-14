# P3C Interpretation Notes

Load this file only for explicit P3C questions, rule mapping, or ambiguity. Normal Java changes use `core.md` instead.

## Retained P3C intent

- Meaningful naming; standard Java casing; constants in `UPPER_SNAKE_CASE`.
- No unexplained business magic values.
- Correct object equality/hash semantics.
- Safe collection mutation/view usage.
- Explicit, bounded concurrency/resource ownership.
- Braced/readable control flow.
- Preserve exception causes; never swallow exceptions or return from `finally`.
- Safe logging/comments without secrets.
- Parameterized SQL and bounded/deterministic data access.

## Modern overrides

- Do **not** require `Service/DAO` interface + `Impl` pairs without a real contract boundary.
- Prefer modern Java 17/21 language/JDK APIs over historical examples.
- Java 21 virtual threads are not forced into classic platform-thread-pool rules; still bound scarce downstream resources.
- Follow the repository's actual Spring/persistence architecture instead of reproducing historical layering.
- Established formatter/repository conventions may supersede style-only P3C prescriptions.

Executable checking is implemented with maintained PMD 7 rules, not Alibaba legacy PMD rule classes.

For rationale, search `P3C modernization decisions` in `docs/rules/deep-reference.md`.