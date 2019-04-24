#!/bin/bash -e

# shellcheck disable=SC1091
source ./parse-argv.sh

function run-test {
    local test_file snapshot_file snapshot USAGE argv test_result \
          output1 output2 output3 \
          error

    local -i status
    test_file=$1

    USAGE="$(grep -vP '^\$ ' < "$test_file")"
    argv="$(grep -oP '^\$ \K(.+)$' < "$test_file")"
    snapshot_file="$(dirname "$test_file")/__snapshots__/$(basename "$test_file")"

    printf 'Running test: %s... ' "$test_file"
    if ! test -f "$snapshot_file"; then
        printf '\nSnapshot file not found: %s\n' "$snapshot_file" >&2
        exit 1
    fi

    snapshot="$(cat "$snapshot_file")"

    # shellcheck disable=SC2034
    local -a programs=()

    parse-argv 'programs'
    status=$?

    printf -v output1 -- '%s\n\n' "$USAGE"
    printf -v output2 -- '$ %s' "$argv"

    if test "$status" -eq 0; then
        printf -v output3 -- ''
    else
        printf -v output3 -- 'ERROR: %s' "$error"
    fi

    printf -v test_result -- '%s%s%s' "$output1" "$output2" "$output3"

    if [[ "$snapshot" != "$test_result" ]]; then
        printf ' failed!\n\nTest: %s did not match snapshot\n\n' "$test_file" >&2
        printf '%s' "$output1"
        diff -Naurd --label='snapshot' <(printf '%s' "$snapshot") --label='test-result' <(printf '%s' "$test_result") >&2
        exit 1
    else
        printf ' pass.\n'
    fi
}

function run-tests {
    if test -z "$1"; then
        local t
        for t in tests/argv/*.argv; do
            run-test "$t"
        done
    else
        run-test "$1"
    fi
}

run-tests "$1"
