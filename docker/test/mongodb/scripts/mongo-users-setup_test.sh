#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cp "$script_dir/mongo-users-setup.sh" "$tmpdir/"
mkdir -p "$tmpdir/bin"

cat > "$tmpdir/bin/mongod" <<'SCRIPT'
#!/bin/sh
exit 0
SCRIPT
chmod +x "$tmpdir/bin/mongod"

cat > "$tmpdir/mongo-engine-wait.sh" <<'SCRIPT'
#!/bin/sh
exit 0
SCRIPT
chmod +x "$tmpdir/mongo-engine-wait.sh"

cat > "$tmpdir/mongo-shell.sh" <<'SCRIPT'
#!/bin/sh
printf '%s\n' "$*" >> "$MONGO_USERS_SETUP_TEST_OUTPUT"
SCRIPT
chmod +x "$tmpdir/mongo-shell.sh"

run_setup() {
  output="$1"
  shift

  (
    cd "$tmpdir"
    env -i PATH="$tmpdir/bin:/usr/bin:/bin" MONGO_USERS_SETUP_TEST_OUTPUT="$output" "$@" bash ./mongo-users-setup.sh
  ) >/dev/null
}

backup_only_output="$tmpdir/backup-only-output"
run_setup "$backup_only_output" \
  MONGO_USER_ROOT_NAME=root \
  MONGO_USER_ROOT_PASSWORD=password \
  MONGO_USER_BACKUP_NAME=backup \
  MONGO_USER_BACKUP_PASSWORD=backup-password

grep -F "user: 'backup'" "$backup_only_output"
grep -F "role: 'backup'" "$backup_only_output"

app_only_output="$tmpdir/app-only-output"
run_setup "$app_only_output" \
  MONGO_USER_ROOT_NAME=root \
  MONGO_USER_ROOT_PASSWORD=password \
  MONGO_DB_NAME=test \
  MONGO_USER_APP_NAME=app \
  MONGO_USER_APP_PASSWORD=app-password

if grep -F "role: 'backup'" "$app_only_output"; then
  echo "backup user was created without backup credentials" >&2
  exit 1
fi
