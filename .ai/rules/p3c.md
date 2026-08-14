# P3C Interpretation Notes

Load this file only for explicit P3C questions, rule mapping, or ambiguity. Normal Java changes use `core.md` instead.

## Retained P3C intent

- Meaningful naming; standard Java casing; constants in `UPPER_SNAKE_CASE`.
- No unexplained business magic values.
- Correct object equality/hash semantics and precise numeric handling.
- Safe collection mutation/view/comparator usage.
- Explicit, bounded concurrency/resource ownership with reliable lock/signal cleanup.
- Braced/readable control flow.
- Preserve exception causes; never swallow exceptions or return from `finally`.
- Safe, appropriately scoped logging without secrets.
- Parameterized SQL, explicit null semantics, and bounded/deterministic data access.
- Stable API/RPC presence semantics: do not silently collapse absent values into `0`/`false` defaults.
- Reproducible dependency/version governance for Maven builds.
- Sensitive-output minimization plus abuse/replay controls for costly operations.

## Modern overrides

- Do **not** require `Service/DAO` interface + `Impl` pairs without a real contract boundary.
- Do **not** require wrapper types for every POJO field; preserve absent/null semantics only where the contract needs them.
- Prefer modern Java 17/21 language/JDK APIs over historical examples.
- Java 21 virtual threads are not forced into classic platform-thread-pool rules; still bound scarce downstream resources.
- Follow the repository's actual Spring/persistence/database architecture instead of reproducing historical layering, JOIN limits, table thresholds, or blanket database-feature bans.
- Established formatter/repository conventions may supersede style-only P3C prescriptions.

Executable checking is implemented with maintained PMD 7 rules, not Alibaba legacy PMD rule classes.

For rationale, search `P3C modernization decisions` in `docs/rules/deep-reference.md`.