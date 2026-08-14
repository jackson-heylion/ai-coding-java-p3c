# Deep Engineering Reference

This is a **level-3 reference**, not default AI context. Search/find only the relevant heading when a concise rule is insufficient.

## Java: null, equality, collections

Treat persistence/RPC/cache/deserialized values as nullable unless contracts prove otherwise. Prefer `Objects.equals` for nullable objects. Do not use `==` for wrapper/reference semantic equality. Keep Map/Set key equality stable. Do not structurally modify collections from enhanced `for`; do not treat `Arrays.asList` or `subList` as ordinary mutable `ArrayList` instances.

## Java: concurrency and virtual threads

Bound scarce downstream resources even when Java 21 virtual threads are used. For platform-thread pools, make sizing, queues, rejection, naming, and lifecycle explicit. Clean pooled-thread `ThreadLocal` state in `finally`. Avoid locks around slow I/O. Preserve cancellation, timeout, observability, and request context.

## Java: time, resources, logging

Prefer `java.time`; make timezone semantics explicit at boundaries. Use try-with-resources for owned `AutoCloseable` resources. Use parameterized logs; avoid duplicate log-and-rethrow chains and never log secrets/tokens/sensitive payloads.

## Spring: boundaries and transactions

Prefer constructor injection. Keep controllers focused on transport concerns. Put coherent business transaction boundaries in the service/application layer used by the repository. Understand proxy/self-invocation behavior. Avoid slow remote calls while holding DB transactions unless required by consistency. Use after-commit/outbox patterns when side effects depend on successful commit.

## Spring: async, scheduling, caching

Do not assume async/scheduled work inherits transaction, security, tenant, MDC, or trace context. Make retry/overlap semantics and idempotency explicit. Cache keys must include required identity/tenant scope; define invalidation and source-of-truth behavior.

## Database: correctness and concurrency

Use parameter binding. Whitelist dynamic identifiers. Back application uniqueness with DB constraints or another atomic mechanism. For concurrent updates choose an explicit mechanism: unique constraint, conditional update, optimistic version, or lock. Check affected-row counts when correctness depends on one-row mutation.

## Database: performance and rollout

Avoid unbounded reads/updates/deletes and N+1 access. Use deterministic pagination. Consider filters, joins, ordering, selectivity, and existing indexes before adding indexes or caches. Prefer expand/migrate/contract schema rollout. Use exact decimal types for money and explicit time/null semantics.

## API: compatibility and idempotency

Treat public and independently deployed RPC contracts as stable. Prefer additive changes. Keep serialization of dates/enums/decimals/IDs stable unless intentionally migrated. Bound pagination and whitelist sort/filter fields. Define idempotency for retried commands using keys, unique constraints, or atomic state transitions.

## Security: authorization and input

Authentication establishes identity; authorization still must check operation plus object/tenant/data scope. Derive authoritative user/tenant/role/ownership fields server-side. Treat HTTP, MQ, RPC, files, URLs, redirects, templates, expressions, SQL fragments, and configuration across trust boundaries as untrusted.

## Security: secrets, SSRF, files, deserialization

Never hard-code or log secrets. Do not disable TLS verification. For outbound URLs validate scheme/destination and protect internal networks. For files validate size/type, generate safe storage paths, prevent traversal, and authorize downloads. Avoid arbitrary polymorphic deserialization or dynamic code execution.

## Testing: scope and determinism

Use the narrowest test that proves behavior: unit → component/slice → integration → full application. A bug fix should get a focused regression test when practical. Control time/randomness; avoid sleeps when conditions/latches work. Do not use `@SpringBootTest` for ordinary Java logic.

## Testing: databases, APIs, security, concurrency

Use the production DB engine when dialect/locking/transaction behavior matters. Test contract validation/status/serialization when APIs change. Security changes need denial-path tests. Concurrency/idempotency logic should test duplicate/lost-update/retry invariants rather than only sequential happy paths.

## P3C modernization decisions

Preserve P3C engineering intent, not historical ceremony. Do not mandate Service/DAO interface + `Impl` pairs. Prefer modern collection/time/language APIs over old examples. Java 21 virtual threads are not forced into classic `ThreadPoolExecutor` rules. Repository architecture and formatter conventions override obsolete style prescriptions.

## Local validation escalation

Do not run every check after every edit. During iteration, run the narrowest affected test or compile action. Use direct PMD static analysis when only static rules need feedback. Use one combined Maven lifecycle (`-Pp3c-local verify`) for final full validation instead of `verify` followed by another `verify`. PMD incremental analysis should stay enabled so unchanged files reuse cached results.