# Adoption Guide

Use the installer that matches the operating system. The installed rules are platform-neutral; only the local command wrapper differs.

## What gets installed

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
scripts/verify-java.sh
scripts/verify-java.ps1
scripts/verify-java.cmd
```

Existing files are preserved by default. Use `--force` / `-Force` only when replacement is intentional.

## New project

`new` mode may create the target directory and does not require `pom.xml` yet. This is useful when the Java/Maven project is being created at the same time.

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

If the new project does not have a `pom.xml` yet, create the Maven project first and then enable the PMD profile after the POM exists.

## Existing Maven project

`existing` mode requires `pom.xml` and does not overwrite existing template-managed files.

### macOS / Linux

```bash
bash scripts/install.sh existing ../legacy-service
```

### Windows CMD

```bat
scripts\install.cmd existing ..\legacy-service
```

### Windows PowerShell

```powershell
powershell -File scripts\install.ps1 existing ..\legacy-service
```

Review any `SKIP:` messages. Existing `AGENTS.md` should usually be merged deliberately rather than overwritten.

## Enable PMD automatically

POM modification is opt-in. The installer creates `pom.xml.ai-p3c.bak` before patching.

### macOS / Linux

```bash
bash scripts/install.sh existing ../legacy-service --patch-pom
```

### Windows PowerShell

```powershell
powershell -File scripts\install.ps1 existing ..\legacy-service -PatchPom
```

### Windows CMD

```bat
scripts\install.cmd existing ..\legacy-service -PatchPom
```

If automatic POM patching is not desired, copy `examples/maven/p3c-local-profile.xml` into the project's `<profiles>` section manually.

## Replace template-managed files

Use only when you intentionally want this repository's versions to replace files in the target project.

```bash
# macOS / Linux
bash scripts/install.sh existing ../my-service --force
```

```powershell
# Windows
powershell -File scripts\install.ps1 existing ..\my-service -Force
```

Project-specific rules should normally be preserved and merged rather than overwritten.

## Verify after adoption

### macOS / Linux

```bash
bash scripts/verify-java.sh auto
```

### Windows CMD

```bat
scripts\verify-java.cmd auto
```

### Windows PowerShell

```powershell
powershell -File scripts\verify-java.ps1 auto
```

`auto` skips documentation-only changes, scopes multi-module Maven builds to changed modules when safe, and performs one final Maven lifecycle rather than redundant compile/test/verify passes.

## Recommended migration order for an old project

1. Install without `--force` / `-Force`.
2. Merge `AGENTS.md` if the project already has repository instructions.
3. Review `.ai/rules/core.md` and add only real project-specific constraints.
4. Run focused tests for the touched module.
5. Enable `p3c-local` and run `static` once to measure historical violations.
6. Do not mass-fix legacy violations; enforce the baseline on new/changed code first.

This staged approach keeps adoption low-risk and avoids turning a coding-standard rollout into an unrelated refactoring project.
