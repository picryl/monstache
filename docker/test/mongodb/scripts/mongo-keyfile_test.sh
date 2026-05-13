#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

keyfile="$tmpdir/mongodb-keyfile"
keyvalue="bW9uc3RhY2hlLWtleWZpbGUtdGVzdA=="

MONGO_KEY_FILE="$keyfile" MONGO_REPLICA_SET_KEY="$keyvalue" ./mongo-keyfile.sh > "$tmpdir/path"

grep -F "$keyfile" "$tmpdir/path"
grep -F "$keyvalue" "$keyfile"

mode="$(stat -f '%Lp' "$keyfile" 2>/dev/null || stat -c '%a' "$keyfile")"
test "$mode" = "400"
