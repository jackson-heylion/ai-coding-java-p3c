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

case "$MODE" in
  fast)
    run "${MVN[@]}" -q -DskipTests compile
    run "${MVN[@]}" -q test
    ;;

  full)
    run "${MVN[@]}" -q verify
    ;;

  p3c)
    if ! has_p3c_profile; then
      cat >&2 <<'EOF'
ERROR: Maven profile 'p3c-local' was not found in pom.xml.

Copy the profile from:
  examples/maven/p3c-local-profile.xml

into your project's <profiles> section, then run again:
  bash scripts/verify-java.sh p3c
EOF
      exit 3
    fi
    run "${MVN[@]}" -q -Pp3c-local -DskipTests verify
    ;;

  all)
    run "${MVN[@]}" -q verify
    if has_p3c_profile; then
      run "${MVN[@]}" -q -Pp3c-local -DskipTests verify
    else
      echo "INFO: p3c-local profile not configured; skipping P3C PMD scan."
    fi
    ;;

  help|-h|--help)
    cat <<'EOF'
Local Java verification

Usage:
  bash scripts/verify-java.sh [mode] [project-directory]

Modes:
  fast   compile + tests
  full   normal Maven verify (default)
  p3c    run the optional local P3C PMD profile
  all    normal verify, then P3C if the profile exists

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
