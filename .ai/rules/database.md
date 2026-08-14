# Database Rules

Load only for SQL, persistence, schema, transaction, or ORM changes.

## MUST

- Preserve transaction atomicity and define idempotency for retryable operations.
- Back critical uniqueness/integrity with DB constraints or another atomic mechanism.
- Parameterize values; whitelist dynamic identifiers. Never concatenate untrusted SQL.
- Review UPDATE/DELETE predicates and meaningful affected-row counts.
- Avoid N+1 access and unbounded reads/updates/deletes; batch when volume can be large.
- Paginated queries need deterministic ordering.
- Consider existing indexes/query shape before adding indexes or caches.
- For concurrent writes choose an explicit mechanism: unique constraint, conditional update, optimistic version, or lock.
- Prefer backward-compatible schema rollout; plan non-null additions/backfills/destructive changes.
- Use exact decimal types for money and explicit time/null semantics.
- Follow the repository persistence stack; do not mix JPA/MyBatis/MyBatis-Plus styles casually.
- For MyBatis, never pass untrusted input to `${...}`/raw fragments such as `last(...)`.

## Deeper guidance

Search `docs/rules/deep-reference.md` only for:

- `Database: correctness and concurrency`
- `Database: performance and rollout`
- `Database: SQL null and index semantics`