# Testing Rules

These rules apply to unit tests, slice/layer tests, integration tests, contract tests, and regression tests for Java applications.

## Principles

Tests should protect observable behavior and important invariants. Prefer a small number of meaningful tests over large amounts of brittle implementation-detail coverage.

## MUST

### Test behavior, not implementation details

Prefer asserting:

- returned results;
- persisted state;
- emitted domain/integration effects;
- authorization decisions;
- error contracts;
- important interactions at real boundaries.

Avoid tests that fail merely because private methods, local variables, or internal call ordering changed without changing behavior.

### Regression tests

When fixing a bug, add a regression test when practical that:

1. fails for the original defect;
2. passes after the fix;
3. captures the triggering condition or violated invariant.

### Boundary cases

Test important boundaries relevant to the change, such as:

- null/empty values;
- minimum/maximum values;
- duplicate requests;
- invalid state transitions;
- authorization failures;
- concurrent/retried execution;
- partial dependency failure;
- time/date boundaries;
- money/rounding behavior;
- pagination boundaries.

Do not add irrelevant edge cases simply to increase test count.

### Determinism

Tests must be deterministic.

- Do not depend on execution order.
- Do not depend on wall-clock time without controlling the clock where practical.
- Do not depend on random values without controlling or recording the seed.
- Do not use arbitrary `sleep` calls to wait for asynchronous behavior when a condition/latch/test utility can observe completion.
- Do not depend on developer-machine state, local timezone, or undeclared environment variables.

### Isolation

- A test must clean up or isolate the state it creates.
- Tests must not share mutable static state unintentionally.
- Integration tests must avoid dependence on data left by another test.
- Parallel execution must not create hidden cross-test coupling.

### Assertions

- Assert the business-relevant result, not merely that code executed without throwing.
- Failure messages should make diagnosis possible when the assertion API supports them.
- Avoid overly broad assertions that allow incorrect behavior to pass.
- For exceptions, assert the relevant type and contract; do not catch an exception and silently mark the test successful.

## Test scope

Use the narrowest test that can reliably verify the behavior:

1. pure unit test;
2. component/service test;
3. Spring slice/layer test;
4. integration test with real infrastructure dependency;
5. full application/end-to-end test only when the behavior spans those boundaries.

Do not load the entire Spring context for logic that can be tested as an ordinary Java object.

## Unit tests

- Construct the subject explicitly when possible.
- Mock external boundaries, not every collaborating class.
- Avoid deep mock graphs that mirror implementation structure.
- Do not mock value objects, collections, or simple domain logic unnecessarily.
- Verify interactions only when the interaction itself is part of the behavior (for example, an external command must be emitted once).

## Spring tests

Choose the test style deliberately:

- controller/web slice for HTTP mapping/validation/serialization/security behavior;
- repository/data slice for persistence mappings and queries;
- service/component tests for orchestration;
- `@SpringBootTest` when wiring/full application behavior is actually required.

Do not use `@SpringBootTest` as the default for every test.

## Database tests

For non-trivial SQL/repository behavior, prefer testing against the same database engine as production when dialect/locking/index/transaction semantics matter.

Be cautious with in-memory substitutes when the code depends on:

- vendor-specific SQL;
- collation behavior;
- JSON types;
- locking/isolation;
- generated columns;
- upsert syntax;
- transaction semantics.

Database tests should cover important constraints such as uniqueness, nullability, state transitions, and affected-row behavior when those enforce correctness.

## API tests

When API contracts change, test relevant:

- request validation;
- status code/error model;
- serialization formats;
- authentication/authorization;
- backward-compatible field behavior;
- pagination/filtering/sorting semantics.

Do not assert huge JSON payloads when focused assertions or stable snapshots can express the contract more clearly.

## Security tests

For security-sensitive behavior, include negative tests where appropriate:

- unauthenticated caller;
- authenticated but unauthorized caller;
- wrong tenant/owner;
- tampered/malformed input;
- forbidden state transition.

A happy-path-only security test is insufficient when access control is part of the change.

## Concurrency and idempotency tests

When correctness depends on concurrency, retries, uniqueness, or exactly-once-like behavior, test the invariant rather than assuming sequential execution proves it.

Examples:

- two concurrent creates must not produce duplicates;
- repeated idempotency key returns/reuses the intended result;
- optimistic-lock conflict is handled correctly;
- retried message processing does not duplicate a side effect.

## External dependencies

- Unit tests should not call real third-party services.
- Integration tests that need a dependency should use the repository-approved local/container/test double approach.
- Stub behavior should model relevant success, timeout, malformed response, and failure cases when those paths matter.
- Do not make normal CI depend on an uncontrolled public endpoint.

## Test data

- Keep fixtures small and readable.
- Builders/factories should make important values explicit and provide safe defaults for irrelevant fields.
- Do not use production secrets or personal data in test fixtures.
- Avoid giant shared fixtures that make tests hard to understand and couple unrelated scenarios.

## Naming

Test names should describe behavior or scenario clearly.

Good examples:

```text
createsOrderWhenRequestIsValid
rejectsOrderFromAnotherTenant
returnsSameResultWhenIdempotencyKeyIsRetried
```

Use the repository's existing naming convention if one is established.

## Coverage

Coverage is a signal, not the goal.

Do not generate low-value tests solely to raise line coverage. Prioritize critical branches, business invariants, failure modes, and code with meaningful change risk.

## AI behavior

When modifying behavior, AI should:

1. inspect nearby tests first;
2. reuse the established test framework/style;
3. add the smallest useful regression/behavior tests;
4. run the narrowest relevant tests first;
5. run broader verification when practical;
6. report any validation that could not be performed.

Do not delete or weaken an existing test just because a code change made it fail unless the expected behavior intentionally changed.

## AI checklist

Before finishing a test-related change, verify:

1. Does the test protect behavior/invariants rather than implementation details?
2. Does a bug fix have a regression test where practical?
3. Are important failure/boundary cases covered?
4. Is the test deterministic and isolated?
5. Is the chosen test scope no broader than necessary?
6. Are database/API/security semantics tested at the appropriate boundary?
7. Are mocks limited to meaningful boundaries?
8. Are fixtures free of secrets/personal data?
9. Would the test fail for the defect or regression it is intended to catch?
10. Were relevant tests actually run?
