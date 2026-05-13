#!/bin/bash

set -euo pipefail

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-monstache}"
export SEARCH_FLAVOR="${SEARCH_FLAVOR:-elasticsearch}"
export SEARCH_IMAGE="${SEARCH_IMAGE:-docker.elastic.co/elasticsearch/elasticsearch-oss:7.0.0}"

compose_files=(-f docker-compose.test.yml)

if [ "$SEARCH_FLAVOR" = "opensearch" ]; then
  compose_files+=(-f docker-compose.opensearch.yml)
elif [ "$SEARCH_FLAVOR" != "elasticsearch" ]; then
  echo "Unsupported SEARCH_FLAVOR: $SEARCH_FLAVOR" >&2
  exit 1
fi

# The network created by docker will be called ${COMPOSE_PROJECT_NAME}_test as we have the network test in docker-compose

cleanup() {
  docker compose "${compose_files[@]}" down --remove-orphans
}

trap cleanup EXIT

cleanup
docker compose "${compose_files[@]}" up --force-recreate --build --abort-on-container-exit --exit-code-from sut
