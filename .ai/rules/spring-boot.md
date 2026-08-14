# Spring Boot Coding Rules

These rules apply when working with Spring Framework or Spring Boot code.

## General

### MUST

- Follow the Spring Boot version and architectural style already used by the repository.
- Prefer framework-supported extension points over custom infrastructure when they solve the same problem clearly.
- Do not introduce a new Spring abstraction merely because it exists; use it only when it improves the current design.

## Dependency injection

### MUST

Prefer constructor injection for required dependencies.

Prefer:

```java
@Service
@RequiredArgsConstructor
public class OrderApplicationService {

    private final OrderRepository orderRepository;
}
```

Avoid field injection in new code:

```java
@Autowired
private OrderRepository orderRepository;
```

Do not add `@Autowired` to a single constructor unless required by the project's Spring version/style.

## Component boundaries

### MUST

- Controllers handle transport concerns, validation, authentication context, and response mapping; they should not become transaction/business-logic containers.
- Application/service layers own use-case orchestration when the repository uses that architecture.
- Persistence-specific logic belongs behind the repository/mapper/data-access boundary used by the project.
- Do not bypass existing domain/application boundaries solely for implementation convenience.

## Service interfaces

### MUST

Do **not** create `XxxService` + `XxxServiceImpl` pairs solely because an older P3C naming rule recommends it.

Create an interface when there is a real contract boundary, multiple implementations, external SPI, testing architecture that depends on it, or an existing repository convention that requires it.

Otherwise a concrete Spring service is acceptable:

```java
@Service
public class OrderService {
    // ...
}
```

## Transactions

### MUST

- Place transaction boundaries around coherent business operations, normally in an application/service layer rather than a controller.
- Understand Spring proxy behavior before relying on self-invocation or non-public `@Transactional` methods.
- Do not perform slow remote calls inside a database transaction unless atomicity requirements justify the coupling.
- Make rollback behavior explicit when checked exceptions or custom semantics matter.
- Avoid long-running transactions and unnecessary lock duration.

### SHOULD

Use transaction synchronization/outbox/event patterns when side effects must occur only after a successful commit.

## Validation

### MUST

- Validate untrusted request input at system boundaries.
- Use Bean Validation where it expresses structural input constraints clearly.
- Keep business invariants in the appropriate domain/application layer rather than relying only on controller annotations.
- Do not trust client-provided identifiers for authorization decisions.

## REST APIs

### MUST

- Keep request/response DTOs separate from persistence entities unless the project explicitly adopts entity exposure.
- Keep error responses consistent with the repository's established error contract.
- Preserve existing API semantics and status codes unless the task requires a contract change.
- Avoid leaking stack traces, SQL details, class names, or secrets to clients.

### SHOULD

- Use explicit DTO names such as `CreateOrderRequest` and `OrderResponse` where they improve clarity.
- Keep controllers thin and testable.

## Configuration

### MUST

- Prefer typed `@ConfigurationProperties` for related configuration groups over scattered string-based `@Value` usage.
- Never commit production credentials, secrets, tokens, or private keys.
- Keep environment-specific values externalized.
- Validate required configuration at startup when failure later would be harder to diagnose.

## Persistence

### MUST

- Follow the repository's chosen persistence technology (JPA, MyBatis, MyBatis-Plus, JDBC, etc.) rather than mixing styles casually.
- Avoid N+1 query patterns and unbounded result loading.
- Pagination, ordering, and uniqueness assumptions must be explicit where correctness depends on them.
- Do not build SQL by concatenating untrusted input.
- Keep transaction and consistency semantics visible in code.

### JPA

When JPA is used:

- Avoid exposing bidirectional entity graphs through JSON serialization.
- Be explicit about fetch behavior where it materially affects performance.
- Be careful with `equals`/`hashCode` on mutable/generated identifiers.

### MyBatis / MyBatis-Plus

When MyBatis or MyBatis-Plus is used:

- Keep SQL/query conditions reviewable.
- Avoid wrapper chains that hide important business predicates.
- Do not use raw `${...}` interpolation with untrusted values.
- Verify generated UPDATE/DELETE statements have the intended predicates.

## Async and scheduling

### MUST

- Do not assume `@Async` or scheduled work inherits request/transaction context safely.
- Propagate required trace/tenant/security context deliberately.
- Make scheduled jobs idempotent when retries or overlapping execution are possible.
- Configure executors explicitly for production workloads.

## Caching

### MUST

- Define cache keys and invalidation semantics explicitly.
- Do not cache security-sensitive results without understanding identity/tenant scoping.
- Do not treat cache as the source of truth unless the architecture explicitly says so.
- Account for cache penetration, stampede, stale data, and distributed invalidation where relevant.

## Security

### MUST

- Authorization must be enforced server-side.
- Do not disable CSRF/CORS/security filters as a shortcut without understanding the deployment model.
- Avoid logging credentials, bearer tokens, session identifiers, or sensitive claims.
- Treat deserialization, file upload, redirects, URLs, SQL fragments, templates, and expression inputs as untrusted.

## Observability

### SHOULD

- Preserve trace/request identifiers across service boundaries where infrastructure supports it.
- Emit useful metrics for important failure/retry/latency paths.
- Prefer structured, stable log fields over large object dumps.

## Tests

### MUST

Use the narrowest test scope that proves the behavior:

- plain unit tests for pure logic;
- slice tests when Spring integration is needed for one layer;
- full `@SpringBootTest` only when the behavior genuinely requires the application context.

Do not replace meaningful assertions with mocks that merely verify implementation details.
