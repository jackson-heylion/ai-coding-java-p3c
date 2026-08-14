# Project AI Instructions

## Load minimally

For Java work read `.ai/rules/core.md`; load domain rules only when triggered. Use `.agents/skills/java-development/SKILL.md` for workflow. Search one heading in `docs/rules/deep-reference.md` only when concise rules are insufficient.

## Priority

1. explicit requirement
2. security/correctness/data integrity/public contract
3. existing project architecture/conventions
4. applicable domain rule
5. core Java/P3C baseline

Java 17/21 standard syntax is first-class. Use PMD 7 only.

## Project-specific additions

Keep only constraints that materially differ from the shared baseline, e.g. persistence technology, response/error contract, transaction/tenant convention, logging/trace convention, or module compatibility requirements.

## Verification budget

Use the native launcher for the current OS:

```text
macOS/Linux        bash scripts/verify-java.sh <mode>
Windows CMD        scripts\verify-java.cmd <mode>
Windows PowerShell powershell -File scripts\verify-java.ps1 <mode>
```

Modes:

- `compile` — compile risk only
- `test` — behavior; already compiles
- `static` — PMD only
- `auto` — normal final check
- `all` — broad/high-risk/root build change

Use `TEST` and `MODULES` environment variables to narrow scope. Do not run every mode as a ritual. Docs/rules-only changes need no Java build. Fix current-change failures, not unrelated legacy debt.