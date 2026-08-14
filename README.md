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

The mode semantics are the same on every platform: `auto`, `compile`, `test`, `static`, `verify`, `all`.

## Install into a new project

Clone/download this repository, then install the standards skeleton into the target directory.

### macOS / Linux

```bash
bash scripts/install.sh new ../my-service
```

### Windows CMD

```bat
scripts\install.cmd new ..\my-service
```

### Windows PowerShell

```powershell
powershell -File scripts\install.ps1 new ..\my-service
```

`new` mode may create the target directory and does not require `pom.xml` yet.

## Install into an existing Maven project

Existing files are preserved by default.

```bash
# macOS / Linux
bash scripts/install.sh existing ../legacy-service
```

```bat
:: Windows CMD
scripts\install.cmd existing ..\legacy-service
```

```powershell
# Windows PowerShell
powershell -File scripts\install.ps1 existing ..\legacy-service
```

To enable the PMD profile automatically, opt in to POM patching. A backup is created first as `pom.xml.ai-p3c.bak`.

```bash
bash scripts/install.sh existing ../legacy-service --patch-pom
```

```powershell
powershell -File scripts\install.ps1 existing ..\legacy-service -PatchPom
```

Use `--force` / `-Force` only when template-managed files should intentionally be replaced. See `docs/adoption.md` for migration guidance.

## Installed files

```text
AGENTS.md
.ai/rules/
  core.md
  java.md
  spring-boot.md
  database.md
  api.md
  security.md
  testing.md
  p3c.md
.agents/skills/java-development/SKILL.md
config/pmd/p3c.xml
scripts/verify-java.sh
scripts/verify-java.ps1
scripts/verify-java.cmd
```

## Local verification: do only useful work

Examples below use Bash; use the equivalent Windows launcher with the same mode.

```bash
# compile risk only
bash scripts/verify-java.sh compile

# behavior iteration; Maven test already compiles
bash scripts/verify-java.sh test

# PMD only, no full lifecycle
bash scripts/verify-java.sh static

# normal final check: change-aware/module-aware
bash scripts/verify-java.sh auto

# full reactor/high-risk check; one lifecycle with PMD
bash scripts/verify-java.sh all
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
- `static` invokes `pmd:check` directly.
- `all` runs `-Pp3c-local verify` once, not two Maven lifecycles.
- `auto` skips docs/rules-only changes and scopes safe multi-module changes with `-pl ... -am`.
- If Git change detection is unavailable, `auto` safely falls back to the full reactor.
- PMD incremental analysis cache is enabled.
- PMD test-source analysis and XRef linking are disabled by default.
- Avoid routine `clean`; it destroys build/PMD caches.

## Rule loading

Always load only:

```text
AGENTS.md
.ai/rules/core.md
```

Then route by task:

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

Standard Java 17/21 syntax is first-class. `config/pmd/p3c.xml` uses maintained PMD 7 rules: **P3C engineering intent + modern parser**, not a byte-for-byte port of historical Alibaba PMD rules.

## Principles

- Small default context; load detail only when triggered.
- Existing architecture and correctness outrank style ceremony.
- Java 17/21 is not downgraded for tools.
- Verification answers a concrete risk; avoid ritual command sequences.
- Local checks scope to changed behavior/modules whenever safe.
- Cross-platform scripts use native OS tooling.
- Adoption is non-destructive by default.
- Fix current-change failures, not unrelated legacy debt.

## Upstream

Inspired by [alibaba/p3c](https://github.com/alibaba/p3c), Apache License 2.0. This repository is not an official Alibaba project.