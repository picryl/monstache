#!/bin/bash

set -euo pipefail

if command -v mongo >/dev/null 2>&1; then
  exec mongo "$@"
fi

if command -v mongosh >/dev/null 2>&1; then
  exec mongosh "$@"
fi

echo "Neither mongo nor mongosh is available" >&2
exit 1
