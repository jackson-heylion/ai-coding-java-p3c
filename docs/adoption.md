# Adoption Guide

Use the installer that matches the operating system. Rules are platform-neutral; only the command wrapper differs.

## Installed files

```text
.gitattributes
AGENTS.md
.ai/
.agents/
docs/rules/deep-reference.md
config/pmd/p3c.xml
config/pmd/exclude-pmd.properties
examples/maven/p3c-local-profile.xml
scripts/verify-java.sh
scripts/verify-java.ps1
scripts/verify-java.cmd
```

Existing files are preserved by default. Use `--force` / `-Force` only when replacement is intentional. If an existing `.gitattributes` is skipped, merge the script EOL rules manually: `.sh` uses LF; `.ps1`/`.cmd` use CRLF.

## New project

`new` may create the target directory and does not require `pom.xml` yet.

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

If `pom.xml` does not exist yet, create the Maven project first and enable PMD after the POM exists. Keep `config/pmd/exclude-pmd.properties` empty for a new project.

## Existing Maven project

`existing` requires `pom.xml` and preserves existing template-managed files.

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

Review `SKIP:` messages. If the project already has `AGENTS.md`, merge the routing/verification sections deliberately rather than overwriting project-specific instructions.

## Enable PMD automatically

POM modification is opt-in. The installer creates `pom.xml.ai-p3c.bak` before patching.

```bash
# macOS / Linux
bash scripts/install.sh existing ../legacy-service --patch-pom
```

```bat
:: Windows CMD
scripts\install.cmd existing ..\legacy-service -PatchPom
```

```powershell
# Windows PowerShell
powershell -File scripts\install.ps1 existing ..\legacy-service -PatchPom
```

Without automatic patching, merge `examples/maven/p3c-local-profile.xml` into the project's `<profiles>` section manually.

## Existing-project PMD audit

Do not make a legacy project clear every historical violation before adoption. First inventory the current state without failing the build:

```bash
# macOS / Linux
bash scripts/verify-java.sh audit
```

```bat
:: Windows CMD
scripts\verify-java.cmd audit
```

```powershell
# Windows PowerShell
powershell -File scripts\verify-java.ps1 audit
```

`audit` runs PMD with `pmd.failOnViolation=false`: findings are reported, but the command does not fail because of violations. Parser/tooling errors still matter.

For reviewed historical exceptions, add only specific class/rule pairs to:

```text
config/pmd/exclude-pmd.properties
```

Format:

```properties
com.example.LegacyService=AvoidDuplicateLiterals,GodClass
```

Keep exclusions narrow and documented. New projects should normally keep this file empty.

## Normal verification after adoption

```text
macOS/Linux        bash scripts/verify-java.sh auto
Windows CMD        scripts\verify-java.cmd auto
Windows PowerShell powershell -File scripts\verify-java.ps1 auto
```

`auto` skips documentation-only changes, scopes safe multi-module changes, and performs one final Maven lifecycle rather than redundant compile/test/verify passes.

## Replace template-managed files

Use only when replacement is intentional:

```bash
bash scripts/install.sh existing ../my-service --force
```

```powershell
powershell -File scripts\install.ps1 existing ..\my-service -Force
```

Project-specific rules should normally be merged, not overwritten.

## Recommended migration order for an old project

1. Install without force.
2. Merge existing `AGENTS.md` / `.gitattributes` deliberately if present.
3. Review `.ai/rules/core.md`; add only real project-specific constraints.
4. Enable `p3c-local`.
5. Run `audit` once to inventory historical PMD findings.
6. Fix cheap/high-risk historical findings or baseline only reviewed legacy class/rule pairs.
7. Use focused tests during iteration and `auto` as the normal final check.
8. Do not mass-refactor unrelated legacy debt merely to adopt the standard.

This staged approach keeps adoption low-risk while making new and changed code progressively stricter.