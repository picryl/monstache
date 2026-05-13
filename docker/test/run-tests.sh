#!/bin/bash

set -euo pipefail

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-monstache}"
export SEARCH_FLAVOR="${SEARCH_FLAVOR:-elasticsearch}"
export SEARCH_IMAGE="${SEARCH_IMAGE:-docker.elastic.co/elasticsearch/elasticsearch-oss:7.0.0}"
export TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-$PWD/test-results}"
export TEST_REPORT_JSON="${TEST_REPORT_JSON:-/test-results/go-test.json}"
export TEST_REPORT_TITLE="${TEST_REPORT_TITLE:-E2E tests ($SEARCH_FLAVOR: $SEARCH_IMAGE)}"

compose_files=(-f docker-compose.test.yml)
host_report_json="$TEST_RESULTS_DIR/$(basename "$TEST_REPORT_JSON")"
host_report_markdown="$TEST_RESULTS_DIR/go-test-summary.md"

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

mkdir -p "$TEST_RESULTS_DIR"
rm -f "$host_report_json" "$host_report_markdown"

cleanup

status=0
docker compose "${compose_files[@]}" up --force-recreate --build --abort-on-container-exit --exit-code-from sut || status=$?

./go-test-summary.sh "$host_report_json" "$TEST_REPORT_TITLE" > "$host_report_markdown"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  cat "$host_report_markdown" >> "$GITHUB_STEP_SUMMARY"
  echo >> "$GITHUB_STEP_SUMMARY"
fi

exit "$status"
