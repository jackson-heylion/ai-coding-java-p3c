# Local Verification

This repository intentionally keeps verification local. No GitHub Actions or other CI configuration is required.

## Recommended project layout

Copy these files into a Maven project when adopting the template:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
scripts/verify-java.sh
```

If you want the optional P3C PMD scan, also copy the profile from:

```text
examples/maven/p3c-local-profile.xml
```

into the project's `<profiles>` section in `pom.xml`.

## Commands

The script uses `./mvnw` when present and falls back to `mvn`.

### Fast feedback

```bash
bash scripts/verify-java.sh fast
```

Runs:

```text
compile -> tests
```

Use this during implementation.

### Normal project verification

```bash
bash scripts/verify-java.sh full
```

Runs the project's normal Maven `verify` lifecycle. This is the default mode.

### P3C scan

```bash
bash scripts/verify-java.sh p3c
```

Requires the `p3c-local` Maven profile. It runs the adapted ruleset at:

```text
config/pmd/p3c.xml
```

### Full local check

```bash
bash scripts/verify-java.sh all
```

Runs the normal project verification first, then runs P3C when the `p3c-local` profile is configured.

## AI agent behavior

For Java changes, an AI coding agent should prefer the repository-provided local verification command instead of inventing a new command.

Recommended order:

```text
small change
  -> narrow relevant test if known
  -> bash scripts/verify-java.sh fast

before finishing a normal task
  -> bash scripts/verify-java.sh full

when P3C local scanning is configured and compatible
  -> bash scripts/verify-java.sh p3c
```

For a large or risky change, `all` may be appropriate.

## P3C compatibility

Alibaba `p3c-pmd:2.1.1` is built on an older PMD/JDK toolchain. Modern Java source syntax may not always parse correctly under that stack.

Therefore:

- the AI-readable P3C rules remain the baseline regardless of PMD compatibility;
- normal compile/tests/verify remain the primary local correctness checks;
- `p3c-local` is explicit and opt-in;
- do not downgrade modern Java code solely to satisfy limitations of the legacy PMD parser;
- if P3C PMD cannot parse the project's Java version, document that limitation and rely on the rule files plus the project's modern local tooling.

## Multi-module Maven projects

Run from the repository root when possible so `${maven.multiModuleProjectDirectory}` resolves the shared ruleset correctly.

For narrow feedback you may run module-specific Maven commands first, then return to the root-level verification before finishing.

## Scope of fixes

Local verification should gate the current change, not trigger mass cleanup.

Fix:

- failures introduced by the current change;
- relevant existing failures that block validation of the changed code when the fix is small and safe.

Do not automatically refactor unrelated legacy violations.
