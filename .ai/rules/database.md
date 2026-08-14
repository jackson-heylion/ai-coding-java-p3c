# Database Coding Rules

These rules apply to SQL, persistence code, schema changes, migrations, repositories, DAOs, mappers, and ORM usage.

## Scope and priority

Follow existing repository persistence patterns first. Do not introduce a new ORM, SQL builder, cache, sharding strategy, or database abstraction unless the task requires it.

## MUST

### Data correctness

- Preserve transaction atomicity for operations that must succeed or fail together.
- Make transaction boundaries explicit and keep them at the service/application boundary unless the repository uses another established pattern.
- Do not perform irreversible external side effects inside a database transaction unless consistency is deliberately designed for it.
- Define idempotency for operations that may be retried.
- Enforce critical uniqueness and integrity constraints in the database, not only in application code.
- Treat affected-row counts as meaningful when correctness depends on exactly one row being changed.

### Queries

- Never build SQL by concatenating untrusted input.
- Use parameter binding for values.
- Whitelist dynamic identifiers such as sort fields, table names, or column names; they cannot be safely parameterized as ordinary values.
- Avoid `SELECT *` in production query code unless an established framework deliberately requires it.
- Fetch only data needed for the use case.
- Do not introduce N+1 query patterns.
- Paginated queries must have deterministic ordering.
- Large scans, updates, and deletes must be bounded or batched when practical.

### Indexes

When adding or changing a frequently executed query, consider:

- filter columns;
- join columns;
- ordering columns;
- selectivity;
- composite-index column order;
- whether the query can use the intended index.

Do not add redundant indexes without checking existing indexes.

### Schema changes

- Prefer backward-compatible expand/migrate/contract changes for live systems.
- Do not combine a destructive schema change with application code that still depends on the old schema.
- New non-null columns on populated tables require a safe rollout/default/backfill strategy.
- Large table rewrites, full-table updates, and blocking DDL require explicit consideration of production impact.
- Schema migrations must be repeatable or have clear one-time execution semantics according to the migration framework in use.

### Money and precision

- Do not use `float` or `double` for money or exact decimal business values.
- Use `BigDecimal` in Java and an appropriate exact decimal type in the database.
- Define scale and rounding behavior explicitly when calculation semantics require it.

### Time

- Be explicit about timezone semantics.
- Do not mix business-local time, JVM-local time, and UTC implicitly.
- Store and compare timestamps according to the repository's established convention.

### Nullability

- Database nullability and Java nullability must describe the same business semantics.
- Do not rely on primitive defaults such as `0` or `false` to represent an unknown database value.

## Persistence frameworks

### MyBatis / MyBatis-Plus

- Keep SQL readable; move complex queries to XML or the repository's established query mechanism when annotations become difficult to review.
- Do not pass raw user input to `${...}` substitutions.
- Prefer `#{...}` parameter binding for values.
- Review generated update/delete conditions so an empty condition cannot accidentally affect the whole table.
- Do not add `last(...)` fragments from untrusted input.

### JPA / Hibernate

- Do not expose persistence entities as public API DTOs by default.
- Understand lazy-loading boundaries; do not rely on accidental open-session behavior.
- Prevent N+1 queries using deliberate fetch strategy/query design.
- Avoid cascade configurations whose deletion/update scope is not understood.
- Equality for entities must be designed deliberately; do not blindly generate `equals/hashCode` across mutable fields or associations.

## Concurrency

When multiple requests can update the same logical record, decide which consistency mechanism applies:

- unique constraint;
- optimistic locking/version field;
- conditional update;
- pessimistic lock;
- distributed coordination only when database-level mechanisms are insufficient.

Do not use a read-then-write sequence as a uniqueness guarantee without a database constraint or equivalent atomic mechanism.

## Performance

Before introducing a cache to solve a database performance issue, check query shape, indexes, data volume, access pattern, and unnecessary round trips first.

Avoid loading unbounded result sets into memory.

## Logging and observability

- Do not log credentials, access tokens, card data, or sensitive personal data from SQL parameters.
- Slow or failed database operations should include safe diagnostic context such as operation name and relevant identifiers.
- Do not log entire large request/entity objects merely to diagnose persistence failures.

## AI checklist

Before finishing a database-related change, verify:

1. Is transaction scope correct?
2. Is retry/idempotency behavior safe?
3. Can concurrent execution create duplicates or lost updates?
4. Are SQL inputs parameterized and dynamic identifiers whitelisted?
5. Can any update/delete accidentally become unbounded?
6. Are indexes/query plans likely appropriate for the access pattern?
7. Is pagination deterministic?
8. Is the schema rollout backward compatible?
9. Are money/time/null semantics explicit?
10. Are tests covering important integrity and failure cases?
