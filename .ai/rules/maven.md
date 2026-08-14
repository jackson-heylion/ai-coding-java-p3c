# Maven / Dependency Rules

Load only when changing `pom.xml`, Maven plugins, dependency versions, BOMs, or dependency management.

## MUST

- Reuse the repository's existing dependency, BOM/platform, plugin, or JDK capability before adding a new library.
- Keep release/production builds reproducible; do not introduce `SNAPSHOT`, dynamic, or otherwise unstable dependency versions unless the repository explicitly requires them.
- When adding/upgrading a dependency, evaluate meaningful transitive dependency/version-mediation changes instead of accepting them blindly.
- Keep one effective version for the same dependency across a reactor; centralize shared versions with the repository's `dependencyManagement`/BOM/platform convention.
- Respect existing Spring Boot/framework dependency management; do not override managed versions without a concrete compatibility/security reason.
- Use the narrowest correct dependency scope and avoid pulling runtime implementations into API/library modules unnecessarily.
- Follow existing plugin/version-management conventions; do not duplicate plugin configuration across modules when it belongs in parent/plugin management.
- Dependency cleanup or exclusions must account for runtime/reflection/service-loader/plugin usage; do not remove a dependency only because direct imports are absent.

## Validation

For dependency changes, inspect the affected dependency graph only when mediation/transitive impact matters (for example `dependency:tree` on the affected module). Do not run full dependency diagnostics for unrelated Java edits.

## Deeper guidance

Search `docs/rules/deep-reference.md` only for `Maven: dependency governance`.