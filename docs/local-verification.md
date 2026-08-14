# Local Verification

This repository intentionally keeps verification local. No GitHub Actions or other CI configuration is required.

## Modern parser baseline

The executable static-analysis path uses **PMD 7.26.0** only.

It does **not** use `com.alibaba.p3c:p3c-pmd`, PMD 6, or Alibaba's historical PMD parser integration.

P3C is retained as the engineering guideline source; deterministic checks are implemented with maintained PMD 7 Java rules.

PMD 7 natively supports Java 17 and Java 21 standard syntax. This includes Java 21 features such as record patterns and pattern matching for `switch`.

The Maven compiler remains the authority for the project's configured source/release level, while PMD performs semantic/static analysis on the compiled project's source and classpath.

## Recommended project layout

Copy these files into a Maven project when adopting the template:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
scripts/verify-java.sh
```

Also copy the Maven profile from:

```text
examples/maven/p3c-local-profile.xml
```

into the project's `<profiles>` section in `pom.xml`.

## Tool versions

The local profile pins:

```text
maven-pmd-plugin 3.28.0
PMD runtime       7.26.0
```

The profile overrides the PMD runtime modules shipped by the Maven plugin so all PMD modules use the same 7.26.0 version.

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

Runs the project's normal Maven `verify` lifecycle.

### Modern P3C-aligned static analysis

```bash
bash scripts/verify-java.sh p3c
```

Requires the `p3c-local` Maven profile and runs:

```text
PMD 7.26.0
  -> config/pmd/p3c.xml
  -> PMD maintained Java rules
```

Parser/static-analysis errors are not silently ignored: the profile sets `skipPmdError=false` and fails on violations.

### Full local check

```bash
bash scripts/verify-java.sh all
```

Runs normal Maven verification first, then the PMD 7 P3C-aligned scan when the profile exists.

## Java 17 and Java 21

The same PMD 7 ruleset is used for both Java 17 and Java 21 projects.

Recommended practice:

- compile Java 17 projects with a Java 17 toolchain/runtime when practical;
- compile Java 21 projects with a Java 21 toolchain/runtime;
- keep Maven compiler/toolchain settings as the source of truth for the project language level;
- keep PMD type resolution enabled so rules can use the project classpath.

For projects that build under a different launcher JDK, configure Maven Toolchains so compiler and analysis use the intended JDK consistently.

## Java 21 syntax intentionally supported

The local analyzer must accept standard Java 21 syntax, including:

- records;
- sealed classes/interfaces;
- text blocks;
- switch expressions;
- pattern matching for `instanceof`;
- record patterns;
- pattern matching for `switch`;
- modern lambda/method-reference syntax;
- virtual-thread APIs at the source/type-analysis level.

Do not rewrite modern Java code into Java 8-era syntax for static-analysis compatibility.

## Preview features

This repository targets **standard Java 17/21 syntax** by default.

Preview features are a separate policy decision because preview syntax changes between JDK releases. If a consuming project enables preview features, configure the compiler and PMD language version explicitly for that project's JDK rather than weakening the standard baseline.

## AI agent behavior

For Java changes, an AI coding agent should prefer repository-provided local verification commands.

Recommended order:

```text
small change
  -> narrow relevant test if known
  -> bash scripts/verify-java.sh fast

before finishing
  -> bash scripts/verify-java.sh full

static-analysis validation
  -> bash scripts/verify-java.sh p3c

larger/riskier change
  -> bash scripts/verify-java.sh all
```

A PMD parser error is a tooling failure that must be investigated; it must not be treated as permission to skip static analysis silently.

## Multi-module Maven projects

Run from the repository root when possible so `${maven.multiModuleProjectDirectory}` resolves the shared ruleset correctly.

For narrow feedback, module-specific Maven commands may be run first, followed by root-level verification before finishing.

## Scope of fixes

Local verification should gate the current change, not trigger mass cleanup.

Fix:

- failures introduced by the current change;
- relevant existing failures that block validation of the changed code when the fix is small and safe.

Do not automatically refactor unrelated historical violations.
