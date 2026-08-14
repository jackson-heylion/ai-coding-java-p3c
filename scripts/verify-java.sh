#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-auto}"
PROJECT_DIR="${2:-.}"
cd "$PROJECT_DIR"

[[ -f pom.xml ]] || { echo "ERROR: pom.xml not found in $(pwd)" >&2; exit 2; }

if [[ -x ./mvnw ]]; then
  MVN=(./mvnw)
elif command -v mvn >/dev/null 2>&1; then
  MVN=(mvn)
else
  echo "ERROR: Maven not found; install Maven or add ./mvnw." >&2
  exit 2
fi

BASE_ARGS=(-q)
[[ -n "${MAVEN_THREADS:-}" ]] && BASE_ARGS+=(-T "$MAVEN_THREADS")

run() { echo "+ $*"; "$@"; }

has_pmd_profile() {
  grep -Eq '<id>[[:space:]]*p3c-local[[:space:]]*</id>' pom.xml
}

require_pmd_profile() {
  has_pmd_profile || {
    echo "ERROR: missing Maven profile 'p3c-local' (see examples/maven/p3c-local-profile.xml)." >&2
    exit 3
  }
}

scope_args=()
set_scope() {
  local modules="${1:-${MODULES:-}}"
  scope_args=()
  [[ -n "$modules" ]] && scope_args=(-pl "$modules" -am)
}

has_git_worktree() {
  command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

changed_files() {
  {
    git diff --name-only --diff-filter=ACMRD HEAD -- 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | sed '/^$/d' | sort -u
}

is_context_only() {
  local file
  while IFS= read -r file; do
    case "$file" in
      *.md|README*|LICENSE*|docs/*|.ai/*|.agents/*) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

nearest_module() {
  local path="$1" dir
  dir="$(dirname "$path")"
  while [[ "$dir" != "." && "$dir" != "/" ]]; do
    if [[ -f "$dir/pom.xml" ]]; then
      printf '%s' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  [[ -f pom.xml ]] && printf '.'
}

auto_scope() {
  local files file module
  local modules=()

  if ! has_git_worktree; then
    echo "INFO: Git working tree unavailable; using full Maven reactor."
    set_scope ""
    return 0
  fi

  files="$(changed_files)"
  if [[ -z "$files" ]]; then
    echo "INFO: no working-tree changes; nothing to validate."
    return 10
  fi

  if printf '%s\n' "$files" | is_context_only; then
    echo "INFO: only documentation/AI-rule files changed; Java build skipped."
    return 10
  fi

  while IFS= read -r file; do
    case "$file" in
      pom.xml|.mvn/*|mvnw|mvnw.cmd|config/pmd/*|scripts/verify-java.sh|scripts/verify-java.ps1|scripts/verify-java.cmd)
        set_scope ""
        return 0
        ;;
    esac

    module="$(nearest_module "$file")"
    if [[ -z "$module" || "$module" == "." ]]; then
      set_scope ""
      return 0
    fi
    modules+=("$module")
  done <<< "$files"

  if ((${#modules[@]})); then
    local csv
    csv="$(printf '%s\n' "${modules[@]}" | sort -u | paste -sd, -)"
    echo "INFO: changed Maven modules: $csv"
    set_scope "$csv"
  else
    set_scope ""
  fi
}

mvn_run() {
  run "${MVN[@]}" "${BASE_ARGS[@]}" "${scope_args[@]}" "$@"
}

run_compile() { mvn_run -DskipTests compile; }

run_test() {
  local args=(test)
  if [[ -n "${TEST:-}" ]]; then
    args=(-Dtest="$TEST" -Dsurefire.failIfNoSpecifiedTests=false test)
  fi
  mvn_run "${args[@]}"
}

run_static() {
  require_pmd_profile
  mvn_run -Pp3c-local -DskipTests pmd:check
}

run_audit() {
  require_pmd_profile
  mvn_run -Pp3c-local -DskipTests -Dpmd.failOnViolation=false pmd:check
}

run_verify() { mvn_run verify; }

run_all() {
  require_pmd_profile
  mvn_run -Pp3c-local verify
}

case "$MODE" in
  compile) set_scope; run_compile ;;
  test|fast) set_scope; run_test ;;
  static|p3c) set_scope; run_static ;;
  audit) set_scope; run_audit ;;
  verify|full) set_scope; run_verify ;;
  all) set_scope; run_all ;;
  auto)
    if auto_scope; then
      if has_pmd_profile; then
        run_all
      else
        echo "INFO: p3c-local not configured; running scoped Maven verify only."
        run_verify
      fi
    else
      status=$?
      [[ "$status" -eq 10 ]] || exit "$status"
    fi
    ;;
  help|-h|--help)
    cat <<'EOF'
Fast local Java verification

Usage:
  bash scripts/verify-java.sh [auto|compile|test|static|audit|verify|all] [project-dir]

Modes:
  auto     inspect git changes; skip docs-only; scope modules; safely fall back to full reactor
  compile  compile only
  test     test once (already includes compilation); TEST=FooTest narrows tests
  static   direct PMD check only; violations fail
  audit    direct PMD check for legacy adoption; violations are reported but do not fail
  verify   normal Maven verify
  all      one Maven verify with p3c-local enabled (tests + verify + PMD once)

Compatibility aliases: fast=test, p3c=static, full=verify

Optional scope/performance variables:
  MODULES=module-a,module-b   use Maven -pl ... -am
  TEST=OrderServiceTest      run focused Surefire test(s)
  MAVEN_THREADS=1C           opt into Maven parallel reactor execution
EOF
    ;;
  *) echo "ERROR: unknown mode '$MODE'. Use --help." >&2; exit 2 ;;
esac
