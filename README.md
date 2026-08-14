# AI Coding Java P3C

A low-context Java 17/21 AI Coding standard inspired by Alibaba P3C, with modern PMD 7 local validation.

P3C supplies engineering intent. **No Alibaba `p3c-pmd` / PMD 6 runtime is used.**

## Design: progressive disclosure

```text
Level 0  AGENTS.md
         routing + priority + validation budget
            ↓
Level 1  .ai/rules/core.md
         tiny baseline for every Java change
            ↓ only when triggered
Level 2  spring-boot / database / api / security / testing / p3c
         short domain rules
            ↓ only when a rule is insufficient
Level 3  docs/rules/deep-reference.md
         search one relevant heading; do not preload
```

The normal AI turn should **not** read every rule file.

## Structure

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
scripts/verify-java-compatibility.sh
docs/local-verification.md
docs/rules/deep-reference.md
examples/maven/p3c-local-profile.xml
```

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

If more detail is needed, search a heading in `docs/rules/deep-reference.md` instead of reading it all.

## Local verification: do less work

```bash
# compile risk only
bash scripts/verify-java.sh compile

# behavior iteration; Maven test already compiles
bash scripts/verify-java.sh test

# PMD only, no test/verify lifecycle
bash scripts/verify-java.sh static

# recommended final check: change-aware module scope
bash scripts/verify-java.sh auto

# explicit full reactor, one lifecycle with PMD
bash scripts/verify-java.sh all
```

Optional narrowing:

```bash
TEST=OrderServiceTest bash scripts/verify-java.sh test
MODULES=order-server bash scripts/verify-java.sh static
MAVEN_THREADS=1C bash scripts/verify-java.sh all
```

### Performance decisions

- `test` does **not** run a separate `compile` first.
- `static` invokes `pmd:check` directly instead of `verify`.
- `all` runs `-Pp3c-local verify` once instead of `verify` + a second PMD `verify`.
- `auto` skips docs/rules-only changes and scopes known Maven modules with `-pl ... -am`.
- PMD incremental analysis cache is enabled, so unchanged files are not re-analyzed on every local scan.
- PMD test-source analysis and XRef linking are disabled by default for faster production-code feedback.
- Do not routinely run `clean` before local validation; it destroys compiler/PMD caches and forces unnecessary work.

See `docs/local-verification.md` for escalation rules.

## Java / static-analysis baseline

```text
Java                17 / 21
Maven PMD Plugin    3.28.0
PMD runtime         7.26.0
```

Standard Java 17/21 syntax is first-class: records, sealed types, switch expressions, pattern matching, record patterns, and Java 21 virtual-thread APIs where architecturally appropriate.

`config/pmd/p3c.xml` uses maintained PMD 7 rules. The goal is **P3C engineering intent + modern parser**, not a byte-for-byte port of Alibaba's historical PMD rules.

## Install into a Maven project

Copy:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
scripts/verify-java.sh
```

Then copy `examples/maven/p3c-local-profile.xml` into the project's `<profiles>` section.

For normal AI coding, use `auto` as the final local check and escalate to `all` only for broad/high-risk changes.

## Principles

- Small default context; detail is loaded only when triggered.
- Existing architecture and correctness outrank style ceremony.
- Java 17/21 is not downgraded for tools.
- P3C is modernized, not mechanically reproduced.
- Verification answers a specific risk; avoid ritual command sequences.
- Local checks are scoped to changed behavior/modules whenever safe.
- Fix current-change failures, not unrelated legacy debt.

## Upstream

Inspired by [alibaba/p3c](https://github.com/alibaba/p3c), Apache License 2.0. This repository is not an official Alibaba project.