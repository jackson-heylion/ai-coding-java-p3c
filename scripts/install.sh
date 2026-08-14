#!/usr/bin/env bash
set -euo pipefail

MODE="existing"
TARGET="."
FORCE=0
PATCH_POM=0

usage() {
  cat <<'EOF'
Install AI Coding Java P3C into a Maven project.

Usage:
  bash scripts/install.sh [new|existing] [target] [--force] [--patch-pom]

Modes:
  new       create target directory if needed; pom.xml is optional
  existing  require target/pom.xml (default)

Options:
  --force      overwrite template-managed files
  --patch-pom  add the p3c-local profile to pom.xml (creates a .ai-p3c.bak backup)

Examples:
  bash scripts/install.sh new ../my-service
  bash scripts/install.sh existing ../legacy-service
  bash scripts/install.sh existing ../legacy-service --patch-pom
EOF
}

for arg in "$@"; do
  case "$arg" in
    new|existing) MODE="$arg" ;;
    --force) FORCE=1 ;;
    --patch-pom) PATCH_POM=1 ;;
    -h|--help) usage; exit 0 ;;
    --*) echo "ERROR: unknown option $arg" >&2; exit 2 ;;
    *) TARGET="$arg" ;;
  esac
done

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ "$MODE" == "existing" && ! -f "$TARGET/pom.xml" ]]; then
  echo "ERROR: existing mode requires $TARGET/pom.xml" >&2
  exit 2
fi

install_file() {
  local rel="$1" src="$ROOT/$1" dst="$TARGET/$1"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && "$FORCE" -ne 1 ]]; then
    echo "SKIP: $rel already exists"
    return
  fi
  cp "$src" "$dst"
  echo "ADD:  $rel"
}

install_tree() {
  local rel="$1" file
  while IFS= read -r file; do
    install_file "${file#$ROOT/}"
  done < <(find "$ROOT/$rel" -type f | sort)
}

install_file "AGENTS.md"
install_tree ".ai"
install_tree ".agents"
install_file "config/pmd/p3c.xml"
install_file "scripts/verify-java.sh"
install_file "scripts/verify-java.ps1"
install_file "scripts/verify-java.cmd"

chmod +x "$TARGET/scripts/verify-java.sh" 2>/dev/null || true

patch_pom() {
  local pom="$TARGET/pom.xml" fragment="$ROOT/examples/maven/p3c-local-profile.xml" tmp
  [[ -f "$pom" ]] || { echo "ERROR: --patch-pom requires pom.xml" >&2; exit 2; }
  if grep -Eq '<id>[[:space:]]*p3c-local[[:space:]]*</id>' "$pom"; then
    echo "INFO: p3c-local already exists in pom.xml"
    return
  fi

  cp "$pom" "$pom.ai-p3c.bak"
  tmp="$(mktemp)"

  if grep -q '</profiles>' "$pom"; then
    awk -v fragment="$fragment" '
      /<\/profiles>/ && !done {
        while ((getline line < fragment) > 0) print line
        close(fragment); done=1
      }
      { print }
    ' "$pom" > "$tmp"
  else
    awk -v fragment="$fragment" '
      /<\/project>/ && !done {
        print "    <profiles>"
        while ((getline line < fragment) > 0) print line
        close(fragment)
        print "    </profiles>"
        done=1
      }
      { print }
    ' "$pom" > "$tmp"
  fi

  mv "$tmp" "$pom"
  echo "PATCH: pom.xml (backup: pom.xml.ai-p3c.bak)"
}

[[ "$PATCH_POM" -eq 1 ]] && patch_pom

cat <<EOF

Installed into: $TARGET
Mode: $MODE

Next:
  macOS/Linux: bash scripts/verify-java.sh auto
  Windows:     scripts\\verify-java.cmd auto
EOF

if [[ -f "$TARGET/pom.xml" ]] && ! grep -Eq '<id>[[:space:]]*p3c-local[[:space:]]*</id>' "$TARGET/pom.xml"; then
  cat <<'EOF'

Static analysis is not enabled yet.
Either rerun with --patch-pom or merge examples/maven/p3c-local-profile.xml into <profiles> manually.
EOF
fi
