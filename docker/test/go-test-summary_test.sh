#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cat > "$tmpdir/go-test.json" <<'JSON'
{"Time":"2026-05-13T18:00:00Z","Action":"run","Package":"github.com/example/project","Test":"TestPass"}
{"Time":"2026-05-13T18:00:00Z","Action":"pass","Package":"github.com/example/project","Test":"TestPass","Elapsed":0.12}
{"Time":"2026-05-13T18:00:00Z","Action":"run","Package":"github.com/example/project","Test":"TestSkip"}
{"Time":"2026-05-13T18:00:00Z","Action":"skip","Package":"github.com/example/project","Test":"TestSkip","Elapsed":0}
{"Time":"2026-05-13T18:00:00Z","Action":"run","Package":"github.com/example/project","Test":"TestFail"}
{"Time":"2026-05-13T18:00:01Z","Action":"fail","Package":"github.com/example/project","Test":"TestFail","Elapsed":0.34}
{"Time":"2026-05-13T18:00:01Z","Action":"fail","Package":"github.com/example/project","Elapsed":1.23}
JSON

./go-test-summary.sh "$tmpdir/go-test.json" "example report" > "$tmpdir/summary.md"

grep -F "### example report" "$tmpdir/summary.md"
grep -F "| Passed | 1 |" "$tmpdir/summary.md"
grep -F "| Failed | 1 |" "$tmpdir/summary.md"
grep -F "| Skipped | 1 |" "$tmpdir/summary.md"
grep -F "| github.com/example/project | failed | 1.23s |" "$tmpdir/summary.md"
grep -F "| github.com/example/project | TestPass | passed | 0.12s |" "$tmpdir/summary.md"
grep -F "| github.com/example/project | TestFail | failed | 0.34s |" "$tmpdir/summary.md"
