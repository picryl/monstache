#!/bin/bash

set -euo pipefail

keyfile_path="${MONGO_KEY_FILE:-/data/db/mongodb-keyfile}"
keyfile_value="${MONGO_REPLICA_SET_KEY:-bW9uc3RhY2hlLXRlc3Qta2V5ZmlsZQ==}"

if [ ! -f "$keyfile_path" ]; then
  umask 077
  printf '%s\n' "$keyfile_value" > "$keyfile_path"
fi

chmod 400 "$keyfile_path"
printf '%s\n' "$keyfile_path"
