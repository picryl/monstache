#!/bin/bash

set -eo pipefail;

replicaSetStatusIsOk() {
  if ./mongo-shell.sh admin -u "$MONGO_USER_ROOT_NAME" -p "$MONGO_USER_ROOT_PASSWORD" --quiet --eval 'quit(rs.status().ok ? 0 : 1)' > /dev/null 2>&1 ; then
    # echo 'ReplicaSet-Status: OK';
    return 0;
  else
    # echo 'ReplicaSet-Status: Not OK';
    return 1;
  fi
}

replicaSetStatusIsOk;

exit $?;
