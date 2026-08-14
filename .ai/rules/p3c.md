# Alibaba P3C Baseline for AI Coding

This file adapts the Alibaba Java Coding Guidelines (P3C) into concise rules suitable for AI coding agents.

Upstream: https://github.com/alibaba/p3c

P3C is a **baseline**, not an absolute architectural authority. Existing repository conventions and modern Java/Spring rules have higher priority as defined in `AGENTS.md`.

## Rule levels

- **MUST**: mandatory unless a higher-priority repository rule explicitly overrides it.
- **SHOULD**: preferred default; may be overridden by a clear project reason.
- **AVOID**: do not introduce in new code without a concrete reason.

## 1. Naming

### MUST

- Identifiers must not start or end with `_` or `$`.
- Class names use `UpperCamelCase`.
- Method, parameter, member, and local variable names use `lowerCamelCase`.
- Constants use uppercase words separated by underscores.
- Exception classes end with `Exception`.
- Package names use lowercase English words.
- Array brackets belong to the type: `String[] args`, not `String args[]`.
- Names must be meaningful and use consistent English terminology.

### SHOULD

- Abstract base classes use names that clearly convey abstraction, commonly `AbstractXxx` or `BaseXxx` when that matches the repository.
- Tests follow the repository's established naming convention; `XxxTest` is a common default.

### Modern override

P3C contains a rule that Service/DAO implementation classes should end with `Impl` and assumes interface-based Service/DAO design. **Do not create an interface + `Impl` pair solely to satisfy this rule.** Follow `.ai/rules/spring-boot.md` and existing repository architecture.

## 2. Constants

### MUST

- Do not use unexplained magic values for business meaning.
- Use uppercase `L` for long literals, never lowercase `l`.

Prefer named constants, enums, configuration, or value objects.

## 3. Object-oriented programming

### MUST

- Do not use deprecated classes or methods when a supported replacement exists.
- Call `.equals()` only when null safety is guaranteed; otherwise use a null-safe comparison such as `Objects.equals`.
- Do not compare wrapper/reference values with `==` for semantic equality.
- If `equals()` is overridden, `hashCode()` must also be correct.
- Objects used as Map keys or Set values must have correct and stable equality/hash semantics.

### SHOULD

- Keep DTO/DO/VO/entity defaults deliberate. Do not silently assign defaults that hide the difference between "not supplied" and a real business value.
- Provide useful diagnostic representation (`toString` or equivalent) when safe, but never expose secrets/sensitive data.

### Modern override

Use modern Java constructs when they express the same intent better, including records for suitable immutable data carriers. Do not add boilerplate merely because an older P3C example predates records or newer JDK APIs.

## 4. Collections

### MUST

- Do not cast `subList()` to a concrete `ArrayList`.
- Be careful modifying the original list while a `subList()` view is in use.
- Do not call mutating List methods on a fixed-size `Arrays.asList()` result expecting normal `ArrayList` behavior.
- Do not add/remove elements from a collection inside an enhanced `for` loop. Use an iterator, `removeIf`, or another safe operation appropriate to the case.
- Use type-safe collection-to-array APIs.

### SHOULD

- Pre-size collections when the expected size is known and large enough to matter.

### Modern override

Prefer modern collection APIs (`List.of`, `Set.of`, `Map.of`, `toArray(Type[]::new)`, streams where readable) over reproducing historical P3C examples literally.

## 5. Concurrency

### MUST

- Clean up `ThreadLocal` state used on pooled threads, normally in `finally`.
- Threads/executors must have meaningful names for diagnosis.
- Do not create uncontrolled raw threads in application code.
- Do not use executor configurations with accidental unbounded growth.
- Executor sizing, queue capacity, rejection policy, and lifecycle must be understandable.

### SHOULD

- Prefer explicitly configured executors/framework-managed execution over `Executors` factory methods when production behavior must be controlled.
- Avoid sharing a contended random generator where a thread-local generator is more appropriate.

### Modern override

The original guideline predates virtual threads and newer concurrency APIs. If the repository deliberately uses modern concurrency (for example Java 21 virtual threads), follow the configured architecture and its resource/backpressure model rather than forcing a classic `ThreadPoolExecutor` everywhere.

## 6. Control flow

### MUST

- Use braces for `if`, `else`, `for`, `while`, and `do` blocks.
- Switch behavior must be explicit; accidental fall-through is not allowed.
- Complex boolean conditions must remain reviewable.

### SHOULD

Extract meaningful predicates/variables when a condition becomes difficult to understand.

### Modern override

Modern switch expressions do not require old-style `break` conventions. Use the language feature correctly rather than imitating a classic switch statement.

## 7. Exceptions

### MUST

- Never `return` from a `finally` block.
- Never silently swallow exceptions.
- Preserve the cause when wrapping/translating exceptions.
- Transaction rollback behavior must match business consistency requirements.
- Treat values from databases, RPC/API clients, sessions, collections, and caches as potentially absent unless their contract proves otherwise.

### SHOULD

- Catch the narrowest useful exception type.
- Include safe diagnostic context in translated exceptions.

## 8. Logging and comments

### MUST

- Comments must not contradict code.
- Do not use comments to excuse obviously broken design that can be expressed clearly in code.
- Logs/comments must not expose credentials, tokens, secrets, or sensitive data.

### SHOULD

Comments explain why, constraints, invariants, compatibility concerns, or non-obvious trade-offs.

## 9. Database / ORM

### MUST

- SQL must not concatenate untrusted input.
- UPDATE/DELETE statements must have intentional predicates.
- Queries expected to return one row must have a real uniqueness guarantee or explicit deterministic selection.
- Schema/index/query choices must consider data volume and access patterns.

### SHOULD

- Avoid `SELECT *` in stable production queries when explicit columns improve compatibility/performance/readability.
- Keep pagination and ordering deterministic where business correctness depends on it.

### Modern override

Follow the repository's actual persistence stack (JPA, MyBatis, MyBatis-Plus, JDBC, etc.). Do not add a DAO layer or XML mapper simply because a historical example used one.

## 10. AI generation behavior

### MUST

When generating or modifying Java code, the agent must:

1. inspect nearby code before choosing patterns;
2. apply these rules while writing, not as a cosmetic cleanup pass;
3. preserve higher-priority repository conventions;
4. use modern JDK/Spring APIs where appropriate;
5. avoid unrelated legacy cleanup;
6. run relevant build/tests/static analysis when available;
7. fix violations introduced by the current change.

## 11. Rules intentionally not treated as universal mandates

The following types of P3C guidance require repository context and should not be enforced mechanically:

- mandatory Service/DAO interface + `Impl` layering;
- examples tied to old JDK APIs when a modern JDK API is safer/clearer;
- executor rules written before virtual threads when the project explicitly uses a modern concurrency model;
- style rules already superseded by an established formatter or repository standard;
- framework-specific naming/architecture that conflicts with current Spring Boot conventions.

The principle is: **preserve P3C's engineering intent, not historical ceremony.**
