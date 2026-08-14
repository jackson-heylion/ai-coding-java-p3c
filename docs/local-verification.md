# Local Verification

Local only; no CI is required. Use the native launcher for the current OS. Mode semantics are identical.

| Platform | Launcher |
|---|---|
| macOS / Linux | `bash scripts/verify-java.sh <mode>` |
| Windows CMD | `scripts\verify-java.cmd <mode>` |
| Windows PowerShell | `powershell -File scripts\verify-java.ps1 <mode>` |

## Cost model

| Need | Mode | What it avoids |
|---|---|---|
| syntax/compile only | `compile` | tests + PMD + verify plugins |
| behavior feedback | `test` | separate compile + verify + PMD |
| static feedback | `static` | compile/test/verify lifecycle |
| normal final check | `auto` | unrelated modules/docs-only builds |
| explicit full check | `all` | duplicate verify + PMD lifecycle |

`mvn test` already compiles; never run compile immediately before test just for completeness.

## Focused execution

macOS/Linux:

```bash
TEST=OrderServiceTest bash scripts/verify-java.sh test
MODULES=order-server bash scripts/verify-java.sh static
MAVEN_THREADS=1C bash scripts/verify-java.sh all
```

Windows PowerShell:

```powershell
$env:TEST='OrderServiceTest'; powershell -File scripts\verify-java.ps1 test
$env:MODULES='order-server'; powershell -File scripts\verify-java.ps1 static
$env:MAVEN_THREADS='1C'; powershell -File scripts\verify-java.ps1 all
```

`MAVEN_THREADS` is opt-in because not every project/plugin is safe or faster under parallel Maven execution.

## `auto` mode

When Git change information is available, `auto`:

- skips docs/Markdown/AI-rule-only changes;
- scopes module-local changes with `-pl changed-modules -am`;
- uses the full reactor for root build/config or unmapped changes.

It runs **one** scoped `verify`; with `p3c-local`, tests, normal verify plugins, and PMD execute in the same lifecycle.

If Git is unavailable or the directory is not a Git working tree, `auto` safely falls back to the full Maven reactor. Missing Git information is never treated as proof that validation can be skipped.

## Static analysis

`static` runs direct `pmd:check`, not Maven `verify`. PMD incremental analysis is enabled at `target/pmd/pmd.cache`, so unchanged files can reuse cached results.

Local-speed defaults:

- test sources excluded from PMD;
- XRef linking disabled;
- verbose success output disabled;
- type resolution remains enabled;
- PMD errors/violations still fail the check.

Avoid routine `mvn clean`; deleting `target` also deletes build/PMD caches.

## Final-validation policy

Use `auto` for normal feature/fix completion. Escalate to `all` only for root/build/toolchain changes, cross-module architecture changes, broad public contracts, large refactors, or high-risk transaction/security changes.

Do not repeatedly run `test → verify → static → all` unless each step answers a new question.

## Java / parser baseline

Static analysis uses PMD 7 only and supports standard Java 17/21 syntax. Never introduce Alibaba `p3c-pmd`, PMD 6, or source downgrades for parser compatibility.

Compatibility smoke tests are tooling-maintenance checks, not ordinary application-edit checks. The repository provides Bash and PowerShell/CMD launchers for them as well.

## Adoption

See `docs/adoption.md` for new-project and existing-project installation on Windows, macOS, and Linux.