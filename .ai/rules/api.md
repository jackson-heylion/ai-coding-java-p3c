# API Rules

Load only for HTTP/RPC contracts, DTOs, serialization, pagination, or externally consumed behavior.

## MUST

- Treat consumed API behavior as a contract; prefer additive evolution and preserve compatibility unless breaking change is requested.
- Use boundary DTOs instead of exposing persistence entities by default.
- Validate request structure at the boundary; derive authoritative user/tenant/ownership fields server-side.
- Keep HTTP/RPC method, status, error, timeout, retry, and failure semantics explicit and consistent with the repository.
- Never expose stack traces, SQL, secrets, internal hosts/paths, or framework internals to clients.
- Define idempotency for retried commands where duplicate execution is harmful.
- Bound pagination and make ordering deterministic.
- Whitelist client-selectable sort/filter fields before using them in queries/expressions.
- Preserve date/time, enum, decimal, and identifier serialization formats unless intentionally migrated.
- Enforce object/tenant/data-scope authorization; possession of an ID is not authorization.
- Never blindly retry a non-idempotent remote operation.

## Deeper guidance

Search `docs/rules/deep-reference.md` only for `API: compatibility and idempotency`.