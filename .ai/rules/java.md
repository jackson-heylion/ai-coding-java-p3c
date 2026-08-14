# Java Details

Load only when the change needs Java-language/library guidance beyond `core.md`.

## MUST

- Use the repository Java level; Java 17/21 standard features are allowed and preferred when clearer.
- Treat external/persistence/cache/RPC values as nullable unless contracts prove otherwise.
- Use semantic object equality; keep `equals`/`hashCode` consistent and stable for Map/Set keys.
- Do not structurally modify collections from enhanced `for`; respect `Arrays.asList`/`subList` view semantics.
- For exact decimal values, do not construct `BigDecimal` from a binary floating-point literal/value; prefer decimal text or `BigDecimal.valueOf(...)`. When scale is not part of equality, compare numerically with `compareTo(...) == 0`.
- Do not use `==`/`!=` for approximate `float`/`double` equality; use domain-appropriate tolerance or exact decimal/integer representation.
- Preserve exception causes; avoid broad catches unless required at a boundary.
- Use try-with-resources for owned `AutoCloseable` resources.
- A manually acquired `Lock` must be released in `finally`; completion signals such as `CountDownLatch.countDown()` must execute on every required exit path.
- When acquiring multiple locks/resources, use one consistent ordering to avoid deadlocks.
- Prefer `java.time`; make timezone assumptions explicit at boundaries.
- Use parameterized logging and never log secrets/sensitive payloads.
- Bound platform-thread pools/queues; clean pooled-thread `ThreadLocal` state.
- With Java 21 virtual threads, still bound scarce downstream resources and preserve timeout/cancellation/context semantics.
- Do not create interfaces or generic `Util/Helper/Manager` abstractions without a real boundary/meaning.

## Modern syntax

Records, sealed types, text blocks, switch expressions, pattern matching, record patterns, lambdas/method references, and deliberate Java 21 virtual-thread APIs are valid. Never replace them with Java 8-era boilerplate for tooling compatibility.

## Deeper guidance

Search only the relevant headings in `docs/rules/deep-reference.md`:

- `Java: null, equality, collections`
- `Java: numeric precision, comparators, hot loops`
- `Java: concurrency and virtual threads`
- `Java: time, resources, logging`