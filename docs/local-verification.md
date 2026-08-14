# Local Verification

Local only; no CI is required. The goal is **minimum sufficient feedback**, not running every check after every edit.

## Cost model

| Need | Command | What it avoids |
|---|---|---|
| syntax/compile only | `verify-java.sh compile` | tests + PMD + verify plugins |
| behavior feedback | `verify-java.sh test` | separate compile + verify + PMD |
| static feedback | `verify-java.sh static` | compile/test/verify lifecycle |
| normal final check | `verify-java.sh auto` | unrelated modules/docs-only builds |
| explicit full check | `verify-java.sh all` | duplicate `verify` + PMD lifecycle |

`mvn test` already runs compilation; never run compile immediately before test just for completeness.

## Focused execution

```bash
TEST=OrderServiceTest bash scripts/verify-java.sh test
MODULES=order-server bash scripts/verify-java.sh test
MODULES=order-server bash scripts/verify-java.sh static
MAVEN_THREADS=1C bash scripts/verify-java.sh all
```

- `TEST` narrows Surefire tests.
- `MODULES` uses Maven `-pl ... -am` for known reactor scope.
- `MAVEN_THREADS` is opt-in because not every project/plugin is safe or faster under parallel Maven execution.

## `auto` mode

`auto` inspects working-tree changes:

- docs/Markdown/AI-rule-only change → no Java build;
- module-local change → `-pl changed-modules -am`;
- root `pom.xml`, Maven wrapper/config, PMD config, root/unmapped change → full reactor.

It then runs **one** scoped `verify`; when `p3c-local` exists it activates the profile so tests, normal verify plugins, and PMD all execute in that same lifecycle.

## Static analysis

```bash
bash scripts/verify-java.sh static
```

Runs direct `pmd:check`, not Maven `verify`. The Maven PMD Plugin's check goal triggers PMD analysis itself, so compile/tests/lifecycle phases are unnecessary for static-only feedback.

The `p3c-local` profile enables PMD incremental analysis:

```text
analysisCache=true
target/pmd/pmd.cache
```

After the first scan, unchanged files reuse cached analysis/results. Do not run `mvn clean` routinely before local PMD checks because deleting `target` also deletes the cache.

Other local-speed defaults:

- test sources excluded from PMD by default;
- XRef linking disabled;
- verbose success output disabled;
- type resolution remains enabled for rule quality;
- PMD errors/violations still fail the check.

## Final-validation policy

Use `auto` for normal feature/fix completion. Escalate to `all` only when scope cannot be narrowed safely, such as:

- root/build/plugin/toolchain changes;
- cross-module architecture changes;
- shared public-contract changes with broad consumers;
- large refactors or risky transaction/security changes;
- explicit release-style validation.

Do not repeatedly run `test → verify → static → all` unless each step answers a new question.

## Java / parser baseline

Static analysis uses PMD 7 only and supports standard Java 17/21 syntax. Never introduce Alibaba `p3c-pmd`, PMD 6, or source downgrades for parser compatibility.

Compatibility smoke tests remain available through:

```bash
bash scripts/verify-java-compatibility.sh 17
bash scripts/verify-java-compatibility.sh 21
```

These are tooling-maintenance checks, not something an AI agent should run for ordinary application edits.