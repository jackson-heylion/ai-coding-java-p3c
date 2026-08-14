# Project AI Instructions

## Load minimally

For Java work always read only:

- `.ai/rules/core.md`

Load extra rules only when triggered:

- Spring → `.ai/rules/spring-boot.md`
- SQL/persistence → `.ai/rules/database.md`
- HTTP/RPC → `.ai/rules/api.md`
- auth/input/tenant/secrets → `.ai/rules/security.md`
- behavior/tests → `.ai/rules/testing.md`
- explicit P3C interpretation → `.ai/rules/p3c.md`
- Java language/library edge case → `.ai/rules/java.md`

For implementation/review workflow use `.agents/skills/java-development/SKILL.md`.
If more detail is required, search one relevant heading in `docs/rules/deep-reference.md`; do not preload the whole reference.

## Priority

1. explicit requirement
2. security/correctness/data integrity/public contract
3. existing project architecture/conventions
4. applicable domain rule
5. core Java/P3C baseline

Java 17/21 standard syntax is first-class. Use PMD 7 only; do not add Alibaba `p3c-pmd` or PMD 6.

## Project-specific additions

Put only rules that materially differ from the shared baseline here, for example:

- persistence technology used by each module;
- project response/error contract;
- transaction/tenant conventions;
- logging/trace conventions;
- module-specific compatibility requirements.

Avoid copying shared rules into this file.

## Verification budget

Use the least expensive command that answers the current question:

```bash
bash scripts/verify-java.sh compile   # compile risk only
bash scripts/verify-java.sh test      # behavior; already compiles
bash scripts/verify-java.sh static    # PMD only
bash scripts/verify-java.sh auto      # normal final check
bash scripts/verify-java.sh all       # broad/high-risk/root build change
```

Narrow when known:

```bash
TEST=OrderServiceTest bash scripts/verify-java.sh test
MODULES=order-server bash scripts/verify-java.sh static
```

Do not run `compile → test → verify → static → all` as a ritual. Documentation/rule-only changes need no Java build. Fix failures caused by the current change, not unrelated legacy debt.