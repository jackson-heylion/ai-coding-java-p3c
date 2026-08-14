#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-all}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POM="$ROOT_DIR/examples/compatibility/pom.xml"

if [[ -x "$ROOT_DIR/mvnw" ]]; then
  MVN=("$ROOT_DIR/mvnw")
elif command -v mvn >/dev/null 2>&1; then
  MVN=(mvn)
else
  echo "ERROR: Maven was not found." >&2
  exit 2
fi

java_major() {
  java -XshowSettings:properties -version 2>&1 \
    | awk -F'= ' '/java.specification.version/ {print $2; exit}' \
    | sed 's/^1\.//'
}

run() {
  echo "+ $*"
  "$@"
}

require_java21() {
  local major
  major="$(java_major)"
  if [[ -z "$major" || "$major" -lt 21 ]]; then
    echo "ERROR: Java 21+ is required for the Java 21 syntax smoke test. Current runtime: ${major:-unknown}" >&2
    exit 3
  fi
}

case "$MODE" in
  17)
    run "${MVN[@]}" -q -f "$POM" -pl java17 -am verify
    ;;
  21)
    require_java21
    run "${MVN[@]}" -q -f "$POM" -pl java21 -am verify
    ;;
  all)
    require_java21
    run "${MVN[@]}" -q -f "$POM" verify
    ;;
  help|-h|--help)
    cat <<'EOF'
Java syntax + PMD 7 compatibility smoke tests

Usage:
  bash scripts/verify-java-compatibility.sh [17|21|all]

17   Compile Java 17 syntax and analyze it with PMD 7.26.0
21   Compile Java 21 syntax and analyze it with PMD 7.26.0
all  Run both modules (requires JDK 21+)
EOF
    ;;
  *)
    echo "ERROR: unknown mode '$MODE'. Use --help." >&2
    exit 2
    ;;
esac
