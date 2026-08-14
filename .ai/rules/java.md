# Java Coding Rules

These rules apply whenever Java code is created, modified, reviewed, or refactored.

## Language baseline

Java 17 and Java 21 are first-class targets.

### MUST

- Use the Java version configured by the repository.
- Do not lower the language level or rewrite valid Java 17/21 syntax for static-analysis compatibility.
- Prefer maintained modern JDK APIs over legacy alternatives when compatibility allows.
- Keep Maven compiler/toolchain configuration authoritative for the project's source/release level.

### Modern syntax

Use modern language constructs when they improve clarity, safety, or data modeling and the repository target supports them, including:

- records;
- sealed classes/interfaces;
- text blocks;
- switch expressions;
- pattern matching for `instanceof`;
- Java 21 record patterns;
- Java 21 pattern matching for `switch`;
- lambdas and method references;
- Java 21 virtual-thread APIs when they fit the system's concurrency/backpressure design.

Do not replace these constructs with Java 8-era boilerplate merely because an older guideline predates them.

## Naming

### MUST

- Classes and records use `UpperCamelCase`.
- Methods, parameters, fields, and local variables use `lowerCamelCase`.
- Constants use `UPPER_SNAKE_CASE`.
- Packages use lowercase names.
- Exception classes end with `Exception`.
- Names describe domain meaning rather than implementation accidents.
- Avoid unexplained abbreviations and mixed-language identifiers.

## Null safety

### MUST

Treat values from persistence, RPC/API clients, maps, caches, deserialization, and external libraries as nullable unless their contract proves otherwise.

- Do not dereference nullable values without handling the null case.
- Prefer `Objects.equals(a, b)` for nullable object equality.
- Avoid deep call chains when intermediate nullability is unclear.
- Do not use `Optional` for entity fields, DTO fields, or method parameters unless the existing project explicitly does so.
- Use `Optional` for return values only when absence is a normal and meaningful result and it improves the API.

## Equality

### MUST

- Compare wrapper/reference values by semantic equality, not `==`.
- If `equals()` is overridden, `hashCode()` must also be correct.
- Map keys and Set elements must have stable equality/hash semantics.
- Prefer enum equality with `==`.

## Constants and magic values

### MUST

Do not introduce unexplained business constants in executable code.

Prefer domain enums, named constants, configuration, or value objects where they make meaning explicit.

Bad:

```java
if (status == 3) {
    // ...
}
```

Better:

```java
if (status == OrderStatus.COMPLETED) {
    // ...
}
```

## Collections

### MUST

- Do not structurally modify a collection from an enhanced `for` loop.
- Do not assume `Arrays.asList()` is a normal mutable `ArrayList`.
- Do not cast `subList()` results to concrete collection implementations.
- Avoid returning mutable internal collections directly.
- Avoid repeated linear scans when a Set/Map expresses the operation better.

### SHOULD

- Pre-size collections when the approximate size is known and material.
- Return empty collections instead of `null` unless an existing contract requires otherwise.

## Control flow

### MUST

Use braces for `if`, `else`, `for`, `while`, and `do` blocks even when the body contains one statement.

Keep conditions readable. Extract domain predicates or meaningful boolean variables when a condition becomes difficult to understand.

Prefer guard clauses when they reduce nesting without obscuring business flow.

Modern switch expressions and pattern matching are valid control-flow tools; do not force old-style `switch`/`break` forms when the modern form is clearer.

## Exceptions

### MUST

- Never silently swallow exceptions.
- Never `return` from `finally`.
- Preserve the original cause when translating an exception.
- Add diagnostic context without leaking secrets or sensitive payloads.
- Do not catch broad `Exception` unless the boundary genuinely requires it.
- Do not use exceptions for expected branch control flow.

Bad:

```java
catch (Exception e) {
    throw new RuntimeException("failed");
}
```

Better:

```java
catch (PaymentClientException e) {
    throw new PaymentProcessingException(
            "Failed to process payment for orderId=" + orderId,
            e);
}
```

## Resources

### MUST

Use try-with-resources for `AutoCloseable` resources unless ownership is managed elsewhere by the framework.

Do not manually duplicate close logic that try-with-resources handles safely.

## Date and time

### MUST

Prefer `java.time` APIs.

- `Instant` for timestamps.
- `LocalDate` for calendar dates without timezone.
- `LocalDateTime` only when the domain intentionally has no zone/offset.
- `OffsetDateTime`/`ZonedDateTime` when the offset/zone is part of the domain.
- `DateTimeFormatter` instead of `SimpleDateFormat` for new code.

Make timezone assumptions explicit at system boundaries.

## Concurrency

### MUST

- Do not create unbounded thread pools or queues unintentionally.
- Thread pools must have understandable sizing, queueing, rejection, and naming policies.
- Do not create raw platform threads in application code when the framework/executor model should own them.
- Clean up `ThreadLocal` values in pooled-thread execution paths, preferably with `try/finally`.
- Avoid holding locks while performing network or slow blocking I/O unless required by correctness.

### Java 21 virtual threads

Virtual threads are allowed when the project targets Java 21 and they fit the architecture.

- Do not apply classic platform-thread pool sizing rules mechanically to virtual threads.
- Still bound scarce downstream resources such as database connections, remote-service concurrency, file descriptors, or rate-limited APIs.
- Avoid designs that rely on unbounded task creation merely because virtual threads are cheap.
- Preserve cancellation, timeout, observability, and request-context semantics.

### SHOULD

Prefer structured ownership of executors and framework-managed lifecycle over global static executors.

## Logging

### MUST

- Use parameterized logging instead of string concatenation.
- Do not log passwords, tokens, secrets, complete credentials, or sensitive personal data.
- Include stable identifiers useful for diagnosis, such as `orderId`, `requestId`, or `tenantId`, when appropriate.
- Do not log and rethrow the same exception at every layer.

Prefer:

```java
log.info("Order processed, orderId={}", orderId);
```

Avoid:

```java
log.info("Order processed, orderId=" + orderId);
```

## API design

### MUST

- Keep public contracts explicit about nullability, errors, and ownership where practical.
- Do not expose persistence entities as public API DTOs unless the project deliberately uses that model.
- Preserve backward compatibility when changing public APIs unless breaking change is explicitly requested.

### SHOULD

- Prefer immutable request/value objects where mutation is unnecessary.
- Prefer records for transparent immutable data carriers when supported by the project and framework.
- Prefer small domain-specific types over ambiguous tuples/maps for important business values.

## Methods and classes

### SHOULD

- Keep methods focused on one coherent operation.
- Extract methods based on domain meaning, not arbitrary line-count thresholds.
- Prefer composition over inheritance unless inheritance models a real substitutable relationship.
- Do not create interfaces solely to satisfy a naming convention or to predict hypothetical implementations.
- Avoid generic `Util`, `Helper`, `Manager`, and `Common` abstractions when a domain-specific name is available.

## Comments

### MUST

Comments should explain constraints, invariants, trade-offs, or reasons that are not obvious from the code.

Do not add comments that merely translate the next line of code into prose.

## Static-analysis compatibility

### MUST

- Use PMD 7 for repository-provided Java static analysis.
- Do not add `com.alibaba.p3c:p3c-pmd`, PMD 6, or a legacy parser fallback.
- Treat parser errors on valid Java 17/21 code as tooling defects/configuration issues.
- Never downgrade source syntax solely to appease obsolete analysis tooling.

## Generated changes

### MUST

AI-generated changes must:

- preserve local project conventions;
- avoid unrelated refactoring;
- avoid speculative abstractions;
- compile under the repository's configured JDK;
- include or update tests when behavior changes and the repository has a relevant testing pattern;
- pass configured PMD 7 local analysis before completion when the local profile is installed.
