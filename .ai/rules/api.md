# API Coding Rules

These rules apply to HTTP APIs, RPC contracts, request/response models, serialization, error responses, pagination, and backward compatibility.

## MUST

### Contract first

- Treat externally consumed API behavior as a contract.
- Preserve compatibility unless the task explicitly permits a breaking change.
- Do not rename/remove fields, change meanings, narrow accepted values, or alter status/error semantics casually.
- Prefer additive evolution: add optional fields/endpoints before removing old ones.

### Request/response models

- Do not expose persistence entities directly as public API models by default.
- Use dedicated request/response DTOs for public boundaries.
- Validate input at the boundary and return actionable errors.
- Do not trust client-provided tenant/user/ownership fields when they can be derived from authenticated context.
- Clearly distinguish omitted, null, empty, zero, and false when they have different semantics.

### HTTP semantics

Use HTTP methods consistently with the repository's conventions:

- `GET` for retrieval without side effects;
- `POST` for creation/actions that are not naturally idempotent;
- `PUT` for full/idempotent replacement where appropriate;
- `PATCH` for partial updates;
- `DELETE` for deletion.

Do not hide destructive mutations behind `GET`.

### Status and errors

- Use a stable application error model.
- Do not expose stack traces, SQL text, secrets, internal hostnames, or framework exception details to clients.
- Error responses should contain a stable machine-readable code plus a safe human-readable message when the repository supports it.
- Map validation, authentication, authorization, not-found, conflict, and server errors consistently.

### Idempotency

For operations that can be retried by clients, gateways, schedulers, or message-driven callers, explicitly decide whether the operation is idempotent.

For sensitive create/payment/command endpoints where duplicate execution is harmful, use an established idempotency mechanism such as:

- idempotency key;
- business unique key;
- database unique constraint;
- conditional state transition.

Do not rely solely on a pre-check followed by insert/update.

### Pagination

- Paginated endpoints must define deterministic ordering.
- Bound page size.
- Avoid returning unbounded collections from high-cardinality resources.
- Cursor pagination is preferred when offset pagination becomes unstable or expensive for the access pattern.

### Filtering and sorting

- Whitelist supported sort/filter fields.
- Do not feed arbitrary client field names into SQL or expression engines.
- Define default sorting explicitly where ordering matters.

### Versioning and compatibility

Before making a breaking API change, prefer one of:

- additive field evolution;
- tolerant readers;
- endpoint/version coexistence;
- feature flag or staged rollout;
- deprecation period.

Do not introduce a new API version merely for internal refactoring that does not change the contract.

## REST design guidance

Prefer resource-oriented paths:

```text
GET    /orders/{orderId}
POST   /orders
PATCH  /orders/{orderId}
DELETE /orders/{orderId}
```

Use action endpoints when the operation represents a domain command that does not fit cleanly into CRUD, for example:

```text
POST /orders/{orderId}/cancel
```

Avoid RPC-like endpoint proliferation when a clear resource model exists.

## Serialization

- Do not silently change date/time, enum, decimal, or identifier serialization formats.
- Use explicit, stable representations at public boundaries.
- Be careful when adding enum values: some consumers may not be forward-compatible.
- Large integer identifiers exposed to JavaScript clients may require string representation depending on project convention.

## RPC / internal service contracts

- Internal APIs still require compatibility discipline when independently deployed services consume them.
- Define timeout, retry, and failure semantics explicitly.
- Do not retry non-idempotent operations blindly.
- Avoid chatty service contracts that require many sequential network calls for one business operation.
- Treat remote return values as nullable/fallible unless the contract guarantees otherwise.

## Security

- Authentication answers who the caller is; authorization must separately verify what the caller may access.
- Every object-level operation must enforce ownership/tenant/data-scope rules where applicable.
- Do not accept a resource identifier and assume possession of the ID grants access.
- Sensitive operations should have explicit audit context when required by the application.

## Observability

API logs/metrics should make it possible to diagnose failures without exposing sensitive payloads.

Prefer safe context such as:

- request/trace ID;
- route or operation name;
- business identifier where appropriate;
- status/error code;
- duration.

## AI checklist

Before finishing an API change, verify:

1. Is the contract backward compatible?
2. Are request fields validated?
3. Are tenant/user/ownership values derived securely?
4. Are authentication and authorization both enforced?
5. Are retry and idempotency semantics defined?
6. Are errors stable and free of internal details?
7. Is pagination bounded and deterministic?
8. Are sort/filter inputs whitelisted?
9. Are serialization formats unchanged or intentionally migrated?
10. Are relevant contract/integration tests present?
