# AI Coding Java P3C

Repository-scoped Java coding standards for AI coding agents, based on the [Alibaba Java Coding Guidelines (P3C)](https://github.com/alibaba/p3c) and adapted for modern Java / Spring Boot projects.

The goal is not to paste the whole P3C handbook into an AI prompt. Instead, this repository separates the standard into three layers:

```text
AI instructions        -> AGENTS.md + .ai/rules/*.md
AI development flow    -> .agents/skills/java-development/SKILL.md
Deterministic checking -> config/pmd/p3c.xml + Maven/CI
```

## Why

Large coding handbooks are poor system prompts: they consume context, mix obsolete and current advice, and cannot guarantee that generated code actually complies.

This repository therefore uses P3C as a baseline while giving modern Java and repository conventions higher priority when appropriate.

## Structure

```text
.
├── AGENTS.md
├── .ai/
│   └── rules/
│       ├── java.md
│       ├── spring-boot.md
│       └── p3c.md
├── .agents/
│   └── skills/
│       └── java-development/
│           └── SKILL.md
├── config/
│   └── pmd/
│       └── p3c.xml
└── examples/
    └── AGENTS.example.md
```

## Recommended rule priority

When rules conflict, use this order:

1. Existing repository architecture and explicit project requirements
2. Project-specific Java / Spring Boot rules
3. Modern Java platform conventions
4. P3C baseline rules
5. General Java conventions

This is deliberate. Some original P3C recommendations were written for older Java/Spring ecosystems. For example, this template does **not** require every `Service` or `DAO` class to have a matching interface and `Impl` class.

## Use in an existing project

Copy the following directories/files into the project root:

```text
AGENTS.md
.ai/
.agents/
config/pmd/p3c.xml
```

Then adapt `.ai/rules/java.md` and `.ai/rules/spring-boot.md` to the project.

The important pattern is:

```text
AGENTS.md
    -> tells the agent what it MUST follow
.ai/rules/
    -> contains detailed, reviewable coding rules
.agents/skills/
    -> defines the implementation/review workflow
PMD + tests + build
    -> verifies what can be checked deterministically
```

## Maven / P3C PMD

Alibaba P3C provides PMD implementations in `com.alibaba.p3c:p3c-pmd:2.1.1`. The upstream implementation is based on an older PMD/Java toolchain, so test compatibility before making it a hard gate for Java 17/21 syntax.

A representative Maven configuration is:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-pmd-plugin</artifactId>
    <configuration>
        <rulesets>
            <ruleset>${project.basedir}/config/pmd/p3c.xml</ruleset>
        </rulesets>
        <printFailingErrors>true</printFailingErrors>
    </configuration>
    <executions>
        <execution>
            <phase>verify</phase>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
    <dependencies>
        <dependency>
            <groupId>com.alibaba.p3c</groupId>
            <artifactId>p3c-pmd</artifactId>
            <version>2.1.1</version>
        </dependency>
    </dependencies>
</plugin>
```

For newer Java projects, use P3C PMD as a verified subset rather than assuming every upstream rule is still architecturally desirable.

## AI agent compatibility

`AGENTS.md` is the portable entry point. Tools that support repository instructions can read it directly. Tools with a skill mechanism can additionally use `.agents/skills/java-development/SKILL.md`.

The rule files themselves are tool-neutral and remain versioned with the codebase.

## Principles

- Rules live in Git, not in personal IDE settings.
- AI writes compliant code from the start instead of fixing style afterward.
- Static analysis validates rules that can be checked mechanically.
- Existing code is not mass-refactored merely to satisfy a new baseline.
- Modern Java/Spring conventions override obsolete P3C recommendations.
- Every rule should be short, actionable, and reviewable.

## Upstream

This project is inspired by and references [alibaba/p3c](https://github.com/alibaba/p3c), licensed under Apache License 2.0. This repository is not an official Alibaba project.
