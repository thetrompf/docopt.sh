#!/bin/bash
# shellcheck disable=SC1091
source ./build-args.sh
source ./constants.sh
source ./parse-argv.sh
source ./parse-options.sh
source ./parse-programs.sh

function run-test {
    local test_file snapshot_file snapshot USAGE argv test_result \
          output error

    local -i status
    test_file=$1

    USAGE="$(grep -vP '^\$ ' < "$test_file")"
    argv="$(grep -oP '^\$ \K(.+)$' < "$test_file")"
    snapshot_file="$(dirname "$test_file")/__snapshots__/$(basename "$test_file")"

    printf 'Running test: %s...' "$test_file"
    if ! test -f "$snapshot_file"; then
        printf '\nSnapshot file not found: %s\n' "$snapshot_file" >&2
        exit 1
    fi

    snapshot="$(cat "$snapshot_file")"

    # shellcheck disable=SC2034
    local -a programs=() \
             options=() \
             arguments=()

    printf -v test_result '%s\n\n$ %s\n\n' "$USAGE" "$argv"

    parse-options "$USAGE" 'error'
    status=$?

    if test $status -eq 0; then
        parse-programs "$USAGE" 'error'
        status=$?
    else
        printf -v test_result '%sERROR: %s' "$test_result" "$error"
    fi

    if test $status -eq 0; then
        output="$(build-args 2>&1)"
        status=$?
        if test $status -eq 0; then
            $output
        else
            printf -v test_result '%sERROR: %s' "$output" "$error"
        fi
    else
        printf -v test_result '%sERROR: %s' "$test_result" "$error"
    fi

    output=$(parse-argv "$USAGE" "$argv" 2>&1)
    status=$?

    if test $status -eq 0; then
        output="$(print-args 2>&1)"
        printf -v test_result '%s%s' "$test_result" "$output"
    else
        printf -v test_result '%s%s' "$test_result" "$output"
    fi

    if [[ "$snapshot" != "$test_result" ]]; then
        printf ' failed!\n\nTest: %s did not match snapshot\n\n' "$test_file" >&2
        printf '%s\n\n$ %s\n\n' "$USAGE" "$argv" >&2
        diff -Naurd --label='snapshot' <(printf '%s' "$snapshot") --label='test-result' <(printf '%s' "$test_result") >&2
        printf '\n'
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
