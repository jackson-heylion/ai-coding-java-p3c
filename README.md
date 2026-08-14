# AI Coding Java P3C

Low-context Java 17/21 AI Coding standards inspired by Alibaba P3C, with modern PMD 7 local validation.

P3C supplies engineering intent. **No Alibaba `p3c-pmd` / PMD 6 runtime is used.**

## Progressive disclosure

```text
AGENTS.md
  → .ai/rules/core.md
  → triggered domain rule only
  → docs/rules/deep-reference.md heading only when needed
```

Do not preload every rule file.

## Platform support

| Platform | Verification | Installation |
|---|---|---|
| macOS | `bash scripts/verify-java.sh <mode>` | `bash scripts/install.sh ...` |
| Linux | `bash scripts/verify-java.sh <mode>` | `bash scripts/install.sh ...` |
| Windows CMD | `scripts\verify-java.cmd <mode>` | `scripts\install.cmd ...` |
| Windows PowerShell | `powershell -File scripts\verify-java.ps1 <mode>` | `powershell -File scripts\install.ps1 ...` |

Verification modes are equivalent across platforms: `auto`, `compile`, `test`, `static`, `audit`, `verify`, `all`.

## New project

Clone/download this repository, then install the standards skeleton:

```bash
# macOS / Linux
bash scripts/install.sh new ../my-service
```

```bat
:: Windows CMD
scripts\install.cmd new ..\my-service
```

```powershell
# Windows PowerShell
powershell -File scripts\install.ps1 new ..\my-service
```

`new` may create the target directory and does not require `pom.xml` yet. New projects should keep `config/pmd/exclude-pmd.properties` empty.

## Existing Maven project

Existing files are preserved by default:

```bash
bash scripts/install.sh existing ../legacy-service
```

```bat
scripts\install.cmd existing ..\legacy-service
```

```powershell
powershell -File scripts\install.ps1 existing ..\legacy-service
```

POM patching is opt-in and creates `pom.xml.ai-p3c.bak` first:

```bash
bash scripts/install.sh existing ../legacy-service --patch-pom
```

```powershell
powershell -File scripts\install.ps1 existing ..\legacy-service -PatchPom
```

After enabling PMD in an old project, inventory historical findings without failing the build:

```text
macOS/Linux        bash scripts/verify-java.sh audit
Windows CMD        scripts\verify-java.cmd audit
Windows PowerShell powershell -File scripts\verify-java.ps1 audit
```

Reviewed historical class/rule exceptions may be recorded narrowly in `config/pmd/exclude-pmd.properties`. Normal `static`, `auto`, and `all` remain strict.

Use `--force` / `-Force` only when template-managed files should intentionally be replaced. See `docs/adoption.md` for the staged migration flow.

## Installed files

```text
.gitattributes
AGENTS.md
.ai/rules/
.agents/skills/java-development/SKILL.md
docs/rules/deep-reference.md
config/pmd/p3c.xml
config/pmd/exclude-pmd.properties
examples/maven/p3c-local-profile.xml
scripts/verify-java.sh
scripts/verify-java.ps1
scripts/verify-java.cmd
```

The installer is self-contained: every file referenced by `AGENTS.md` or the verification scripts is copied into the target project. If an existing `.gitattributes` is preserved, merge the script EOL rules manually.

## Local verification: do only useful work

Examples use Bash; Windows uses the same mode through its native launcher.

```bash
bash scripts/verify-java.sh compile  # compile risk only
bash scripts/verify-java.sh test     # behavior; test already compiles
bash scripts/verify-java.sh static   # PMD only; violations fail
bash scripts/verify-java.sh audit    # legacy inventory; violations do not fail
bash scripts/verify-java.sh auto     # normal change-aware final check
bash scripts/verify-java.sh all      # broad/high-risk full check
```

Optional narrowing:

```bash
TEST=OrderServiceTest bash scripts/verify-java.sh test
MODULES=order-server bash scripts/verify-java.sh static
MAVEN_THREADS=1C bash scripts/verify-java.sh all
```

Windows uses the same environment variables, e.g. `$env:TEST='OrderServiceTest'` in PowerShell.

### Performance decisions

- `test` does not run a separate `compile` first.
- `static`/`audit` invoke `pmd:check` directly.
- `all` runs `-Pp3c-local verify` once, not two Maven lifecycles.
- `auto` skips docs/rules-only changes and scopes safe multi-module changes with `-pl ... -am`.
- If Git change detection is unavailable, `auto` safely falls back to the full reactor.
- PMD incremental analysis cache is enabled.
- PMD test-source analysis and XRef linking are disabled by default.
- Avoid routine `clean`; it destroys build/PMD caches.

## Rule loading

Always load only `AGENTS.md` and `.ai/rules/core.md`, then route by task:

| Change | Extra rule |
|---|---|
| Spring/Spring Boot | `spring-boot.md` |
| SQL/persistence/schema/transaction | `database.md` |
| HTTP/RPC/DTO/serialization | `api.md` |
| auth/input/secrets/tenant | `security.md` |
| behavior/tests | `testing.md` |
| explicit P3C interpretation | `p3c.md` |
| Java language/library edge case | `java.md` |

If more detail is needed, search one heading in `docs/rules/deep-reference.md` instead of reading it all.

## Java / static-analysis baseline

```text
Java                17 / 21
Maven PMD Plugin    3.28.0
PMD runtime         7.26.0
```

Standard Java 17/21 syntax is first-class. `config/pmd/p3c.xml` uses maintained PMD 7 rules: **P3C engineering intent + modern parser**.

The repository also provides Java 17/21 parser smoke-test launchers for Bash, PowerShell, and Windows CMD; these are tooling-maintenance checks, not ordinary application checks.

## Principles

- Small default context; load detail only when triggered.
- Existing architecture and correctness outrank style ceremony.
- Java 17/21 is not downgraded for tools.
- Verification answers a concrete risk; avoid ritual command sequences.
- Local checks scope to changed behavior/modules whenever safe.
- Cross-platform scripts use native OS tooling.
- Adoption is non-destructive and gradual by default.
- Fix current-change failures, not unrelated legacy debt.

## Upstream

Inspired by [alibaba/p3c](https://github.com/alibaba/p3c), Apache License 2.0. This repository is not an official Alibaba project.