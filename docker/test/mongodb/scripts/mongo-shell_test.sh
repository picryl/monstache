#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/bin"

cat > "$tmpdir/bin/mongosh" <<'SCRIPT'
#!/bin/sh
printf '%s\n' "$0" "$@" > "$MONGO_SHELL_TEST_OUTPUT"
SCRIPT
chmod +x "$tmpdir/bin/mongosh"

MONGO_SHELL_TEST_OUTPUT="$tmpdir/output" PATH="$tmpdir/bin" ./mongo-shell.sh admin --eval "db.runCommand({ ping: 1 })"

grep -F "mongosh" "$tmpdir/output"
grep -F "admin" "$tmpdir/output"
grep -F -- "--eval" "$tmpdir/output"
grep -F "db.runCommand({ ping: 1 })" "$tmpdir/output"
