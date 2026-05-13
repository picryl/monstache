#!/bin/bash

set -euo pipefail

json_file="${1:?usage: go-test-summary.sh GO_TEST_JSON [TITLE]}"
title="${2:-Go test report}"

if [ ! -s "$json_file" ]; then
  {
    echo "### $title"
    echo
    echo "_No Go test JSON output was found._"
  }
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  {
    echo "### $title"
    echo
    echo "_Go test JSON was captured at \`$json_file\`, but \`jq\` is not installed to render a Markdown summary._"
  }
  exit 0
fi

jq -Rrs --arg title "$title" '
  def md:
    tostring
    | gsub("\\|"; "\\|")
    | gsub("\r?\n"; " ");

  def elapsed:
    if . == null then ""
    else ((. * 100 | round / 100 | tostring) + "s")
    end;

  def result:
    if . == "pass" then "passed"
    elif . == "fail" then "failed"
    elif . == "skip" then "skipped"
    else .
    end;

  split("\n")
  | map(select(length > 0) | try fromjson catch empty) as $events
  | [$events[] | select(.Test != null and (.Action == "pass" or .Action == "fail" or .Action == "skip"))] as $tests
  | [$events[] | select(.Test == null and (.Action == "pass" or .Action == "fail" or .Action == "skip"))] as $packages
  | ($tests | map(select(.Action == "pass")) | length) as $passed
  | ($tests | map(select(.Action == "fail")) | length) as $failed
  | ($tests | map(select(.Action == "skip")) | length) as $skipped
  | (
      "### \($title)",
      "",
      "| Result | Count |",
      "| --- | ---: |",
      "| Passed | \($passed) |",
      "| Failed | \($failed) |",
      "| Skipped | \($skipped) |",
      ""
    ),
    (
      if ($packages | length) > 0 then
        "#### Packages",
        "",
        "| Package | Result | Duration |",
        "| --- | --- | ---: |",
        ($packages[] | "| \(.Package | md) | \(.Action | result) | \(.Elapsed | elapsed) |"),
        ""
      else empty end
    ),
    (
      if ($tests | length) > 0 then
        "<details open>",
        "<summary>Tests</summary>",
        "",
        "| Package | Test | Result | Duration |",
        "| --- | --- | --- | ---: |",
        ($tests[] | "| \(.Package | md) | \(.Test | md) | \(.Action | result) | \(.Elapsed | elapsed) |"),
        "",
        "</details>"
      else
        "_No individual Go test events were found._"
      end
    )
' "$json_file"
