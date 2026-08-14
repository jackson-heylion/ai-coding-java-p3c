# Testing Rules

Load only when behavior changes or tests are being modified.

## MUST

- Test observable behavior/invariants, not private implementation structure.
- Bug fixes should get a focused regression test when practical.
- Use the narrowest reliable scope: unit → component/slice → integration → full application.
- Keep tests deterministic and isolated; control time/randomness and avoid arbitrary sleeps.
- Assert business-relevant results/errors/state, not merely that code executed.
- Cover only boundaries relevant to the change: null/empty, duplicates, invalid state, auth denial, retry/concurrency, time/money/pagination, dependency failure.
- Do not default to `@SpringBootTest` for ordinary Java logic.
- Use the production DB engine when dialect/locking/transaction behavior matters.
- Security changes need meaningful negative/denial tests.
- Concurrency/idempotency changes must test duplicate/lost-update/retry invariants when practical.
- Do not call uncontrolled public third-party services from normal tests.
- Do not weaken/delete an existing test merely because new code made it fail unless expected behavior intentionally changed.

## Execution

During iteration prefer `TEST=... bash scripts/verify-java.sh test`. Broaden only when the change scope warrants it.

## Deeper guidance

Search `docs/rules/deep-reference.md` only for:

- `Testing: scope and determinism`
- `Testing: databases, APIs, security, concurrency`