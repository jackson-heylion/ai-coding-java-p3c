# Deep Engineering Reference

This is a **level-3 reference**, not default AI context. Search/find only the relevant heading when a concise rule is insufficient.

## Java: null, equality, collections

Treat persistence/RPC/cache/deserialized values as nullable unless contracts prove otherwise. Prefer `Objects.equals` for nullable objects. Do not use `==` for wrapper/reference semantic equality. Keep Map/Set key equality stable. Do not structurally modify collections from enhanced `for`; do not treat `Arrays.asList` or `subList` as ordinary mutable `ArrayList` instances.

## Java: numeric precision, comparators, hot loops

For exact decimal values, avoid `new BigDecimal(double)` because the binary floating-point approximation is already embedded; prefer decimal text or `BigDecimal.valueOf`. `BigDecimal.equals` includes scale (`1.0` differs from `1.00`), so use `compareTo(...) == 0` only when the domain defines numeric rather than scale-sensitive equality. Approximate `float`/`double` equality needs a domain-appropriate tolerance or an exact representation.

Comparators must satisfy antisymmetry, transitivity, and equality consistency; prefer `Comparator.comparing...`/`thenComparing...` over hand-written `a > b ? 1 : -1` logic that forgets equality or overflows by subtraction. In meaningful hot/large loops, avoid repeated immutable string concatenation when a builder/joiner/collector expresses the operation more efficiently; do not apply this mechanically to trivial concatenation.

## Java: concurrency and virtual threads

Bound scarce downstream resources even when Java 21 virtual threads are used. For platform-thread pools, make sizing, queues, rejection, naming, and lifecycle explicit. Clean pooled-thread `ThreadLocal` state in `finally`. A manually acquired `Lock` must be unlocked in `finally`; completion signals such as latch countdowns must occur on every required exit path. Acquire multiple locks/resources in a consistent global order to reduce deadlock risk. Avoid locks around slow I/O. Preserve cancellation, timeout, observability, and request context.

## Java: time, resources, logging

Prefer `java.time`; make timezone semantics explicit at boundaries. Use try-with-resources for owned `AutoCloseable` resources. Use parameterized logs; avoid duplicate log-and-rethrow chains and never log secrets/tokens/sensitive payloads. Match log severity to operational meaning, preserve useful safe context plus the exception stack for actionable failures, and avoid high-volume logs on hot paths that add cost/noise without diagnostic value.

## Spring: boundaries and transactions

Prefer constructor injection. Keep controllers focused on transport concerns. Put coherent business transaction boundaries in the service/application layer used by the repository. Understand proxy/self-invocation behavior. Avoid slow remote calls while holding DB transactions unless required by consistency. Use after-commit/outbox patterns when side effects depend on successful commit.

## Spring: async, scheduling, caching

Do not assume async/scheduled work inherits transaction, security, tenant, MDC, or trace context. Make retry/overlap semantics and idempotency explicit. Cache keys must include required identity/tenant scope; define invalidation and source-of-truth behavior.

## Database: correctness and concurrency

Use parameter binding. Whitelist dynamic identifiers. Back application uniqueness with DB constraints or another atomic mechanism. For concurrent updates choose an explicit mechanism: unique constraint, conditional update, optimistic version, or lock. Check affected-row counts when correctness depends on one-row mutation.

## Database: performance and rollout

Avoid unbounded reads/updates/deletes and N+1 access. Use deterministic pagination. Consider filters, joins, ordering, selectivity, and existing indexes before adding indexes or caches. Prefer expand/migrate/contract schema rollout. Use exact decimal types for money and explicit time/null semantics.

## Database: SQL null and index semantics

Choose aggregate semantics deliberately: `COUNT(*)` counts rows while `COUNT(column)` excludes nulls; aggregate functions such as `SUM` may return null when no non-null value contributes, so handle that explicitly (for example with an appropriate `COALESCE` when the domain default is truly zero). Use SQL null predicates (`IS NULL`/`IS NOT NULL`) rather than ordinary equality. Keep parameter/column types aligned: implicit casts/conversions can change semantics and prevent useful index access. Bound large `IN` lists/batches according to the actual database/driver limits instead of relying on a historical universal threshold.

## API: compatibility, presence, idempotency

Treat public and independently deployed RPC contracts as stable. Prefer additive changes. Keep serialization of dates/enums/decimals/IDs stable unless intentionally migrated. Preserve the distinction between "not supplied" and explicit `0`/`false`/empty when it changes behavior; primitive/default-initialized DTO fields can accidentally destroy this distinction. Bound pagination and whitelist sort/filter fields. Define idempotency for retried commands using keys, unique constraints, or atomic state transitions.

## Security: authorization and input

Authentication establishes identity; authorization still must check operation plus object/tenant/data scope. Derive authoritative user/tenant/role/ownership fields server-side. Treat HTTP, MQ, RPC, files, URLs, redirects, templates, expressions, SQL fragments, and configuration across trust boundaries as untrusted.

## Security: secrets, SSRF, files, deserialization

Never hard-code or log secrets. Do not disable TLS verification. For outbound URLs validate scheme/destination and protect internal networks. For files validate size/type, generate safe storage paths, prevent traversal, and authorize downloads. Avoid arbitrary polymorphic deserialization or dynamic code execution.

## Security: masking, abuse controls, regex

Apply data minimization to normal responses as well as logs: expose full sensitive values only when the use case and authorization require them; otherwise omit or mask them. For operations that can consume money/resources or be weaponized (verification messages, SMS/email, order/payment actions, exports, password/reset flows), consider rate limits, quotas, replay/duplicate controls, cooldowns, and monitoring appropriate to the threat model. When regex processes attacker-controlled input, bound input size and avoid patterns with catastrophic backtracking/ReDoS risk; prefer simpler parsing or safer regex structure when possible.

## Maven: dependency governance

Before adding a dependency, check whether the JDK, existing dependency set, parent/BOM/platform, or repository utility already provides the capability. Release/production builds should not acquire unstable `SNAPSHOT`/dynamic dependencies unintentionally. When adding or upgrading dependencies, inspect affected transitive mediation (`dependency:tree` or repository equivalent) when it can change runtime behavior, and investigate unexpected version shifts/exclusions. Keep shared versions centralized through the repository's parent/BOM/`dependencyManagement`; avoid divergent effective versions of the same GAV across modules. Respect framework-managed versions unless there is an explicit compatibility/security reason to override them. Use the narrowest correct scope and keep library/API modules from leaking unnecessary runtime implementations.

## Testing: scope and determinism

Use the narrowest test that proves behavior: unit → component/slice → integration → full application. A bug fix should get a focused regression test when practical. Control time/randomness; avoid sleeps when conditions/latches work. Do not use `@SpringBootTest` for ordinary Java logic.

## Testing: databases, APIs, security, concurrency

Use the production DB engine when dialect/locking/transaction behavior matters. Test contract validation/status/serialization when APIs change. Security changes need denial-path tests. Concurrency/idempotency logic should test duplicate/lost-update/retry invariants rather than only sequential happy paths.

## P3C modernization decisions

Preserve P3C engineering intent, not historical ceremony. Do not mandate Service/DAO interface + `Impl` pairs, blanket wrapper types for every POJO field, fixed table/index naming schemes, universal JOIN/IN/table-size thresholds, or blanket bans on database features without project context. Preserve the useful intent instead: presence/null semantics, stable contracts, precise numerics, safe concurrency, bounded data access, dependency reproducibility, and least-privilege security. Prefer modern Java 17/21 collection/time/language APIs over old examples. Java 21 virtual threads are not forced into classic `ThreadPoolExecutor` rules. Repository architecture, database characteristics, framework conventions, and formatter conventions override obsolete style prescriptions.

## Local validation escalation

Do not run every check after every edit. During iteration, run the narrowest affected test or compile action. Use direct PMD static analysis when only static rules need feedback. Use one combined Maven lifecycle (`-Pp3c-local verify`) for final full validation instead of `verify` followed by another `verify`. PMD incremental analysis should stay enabled so unchanged files reuse cached results.