# Spring Boot Rules

Load only for Spring/Spring Boot changes.

## MUST

- Follow the repository's Spring version, layering, persistence style, error model, and configuration conventions.
- Prefer constructor injection for required dependencies.
- Keep controllers on transport/validation/response concerns; keep business orchestration/transactions in the established service/application layer.
- Do not create `Service` + `ServiceImpl` solely for P3C naming history.
- Keep transaction scope coherent and short; avoid remote I/O inside DB transactions unless consistency requires it.
- Validate external input at boundaries; keep business invariants in domain/application code.
- Prefer typed `@ConfigurationProperties` for related settings; never embed production secrets.
- Do not assume `@Async`/scheduled work inherits transaction, security, tenant, MDC, or trace context.
- Make scheduled/retried work idempotent when duplicate execution is possible.
- Define cache key scope, invalidation, and source-of-truth semantics; include identity/tenant scope when required.
- Do not weaken Spring Security/CORS/CSRF/TLS controls as a workaround.

## Tests

Use the narrowest useful Spring test. Do not default to `@SpringBootTest` when a plain unit or slice test proves the behavior.

## Deeper guidance

Search `docs/rules/deep-reference.md` only for:

- `Spring: boundaries and transactions`
- `Spring: async, scheduling, caching`