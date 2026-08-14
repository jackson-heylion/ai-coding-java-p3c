#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-full}"
PROJECT_DIR="${2:-.}"

cd "$PROJECT_DIR"

if [[ ! -f pom.xml ]]; then
  echo "ERROR: pom.xml not found in: $(pwd)" >&2
  exit 2
fi

if [[ -x ./mvnw ]]; then
  MVN=(./mvnw)
elif command -v mvn >/dev/null 2>&1; then
  MVN=(mvn)
else
  echo "ERROR: Maven was not found. Install Maven or add ./mvnw to the project." >&2
  exit 2
fi

run() {
  echo "+ $*"
  "$@"
}

has_p3c_profile() {
  grep -Eq '<id>[[:space:]]*p3c-local[[:space:]]*</id>' pom.xml
}

require_p3c_profile() {
  if has_p3c_profile; then
    return
  fi

  cat >&2 <<'EOF'
ERROR: Maven profile 'p3c-local' was not found in pom.xml.

Copy the profile from:
  examples/maven/p3c-local-profile.xml

into your project's <profiles> section.
EOF
  exit 3
}

maven_property() {
  local expression="$1"
  local value

  value="$("${MVN[@]}" -q help:evaluate \
    -Dexpression="$expression" \
    -DforceStdout 2>/dev/null || true)"

  printf '%s' "$value" | tr -d '\r' | tail -n 1
}

normalize_java_level() {
  local value="$1"

  case "$value" in
    17|1.17)
      printf '17'
      ;;
    21|1.21)
      printf '21'
      ;;
    *)
      return 1
      ;;
  esac
}

detect_java_level() {
  local property value normalized

  for property in maven.compiler.release maven.compiler.source maven.compiler.target; do
    value="$(maven_property "$property")"
    if normalized="$(normalize_java_level "$value" 2>/dev/null)"; then
      printf '%s' "$normalized"
      return 0
    fi
  done

  return 1
}

run_p3c() {
  local java_level
  local pmd_args=(-q -Pp3c-local -DskipTests -Dpmd.skipPmdError=false)

  require_p3c_profile

  if java_level="$(detect_java_level)"; then
    echo "INFO: PMD target Java level detected from Maven: $java_level"
    pmd_args+=("-DtargetJdk=$java_level")
  else
    echo "INFO: Could not resolve Maven compiler level as Java 17/21; PMD 7 will use its modern default language level."
    echo "INFO: Maven compilation remains authoritative for the project's configured Java release."
  fi

  run "${MVN[@]}" "${pmd_args[@]}" verify
}

case "$MODE" in
  fast)
    run "${MVN[@]}" -q -DskipTests compile
    run "${MVN[@]}" -q test
    ;;

  full)
    run "${MVN[@]}" -q verify
    ;;

  p3c)
    run_p3c
    ;;

  all)
    run "${MVN[@]}" -q verify
    run_p3c
    ;;

  help|-h|--help)
    cat <<'EOF'
Local Java verification

Usage:
  bash scripts/verify-java.sh [mode] [project-directory]

Modes:
  fast   compile + tests
  full   normal Maven verify (default)
  p3c    PMD 7 / P3C-aligned static analysis
  all    normal verify + required PMD 7 static analysis

The PMD command automatically detects Java 17/21 from:
  maven.compiler.release
  maven.compiler.source
  maven.compiler.target

Examples:
  bash scripts/verify-java.sh fast
  bash scripts/verify-java.sh full
  bash scripts/verify-java.sh p3c
  bash scripts/verify-java.sh all /path/to/project
EOF
    ;;

  *)
    echo "ERROR: unknown mode '$MODE'. Use --help." >&2
    exit 2
    ;;
esac
