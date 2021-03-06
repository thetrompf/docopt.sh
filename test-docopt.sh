#!/bin/bash
# shellcheck disable=SC1091
source ./constants.sh
source ./parse-programs.sh
source ./parse-options.sh

function run-test {
    local test_file snaphot_file snaphot USAGE test_result \
          output error

    local -i status
    test_file=$1

    USAGE="$(cat "$test_file")"
    snaphot_file="$(dirname "$test_file")/__snapshots__/$(basename "$test_file")"

    printf 'Running test: %s...' "$test_file"
    if ! test -f "$snaphot_file"; then
        printf '\nSnapshot file not found: %s\n' "$snaphot_file" >&2
        exit 1
    fi

    snaphot="$(cat "$snaphot_file")"

    # shellcheck disable=SC2034
    local -a programs=() \
             arguments=() \
             options=()

    printf -v test_result '%s\n\n' "$USAGE"

    parse-options "$USAGE" 'error'
    status=$?

    if test $status -eq 0; then
        parse-programs "$USAGE" 'error'
        status=$?
    fi

    if test $status -eq 0; then
        printf -v test_result '%sPROGRAMS TABLE\n\n' "$test_result"
        output="$(print-programs-table 'error' 2>&1)"
        printf -v test_result '%s%s' "$test_result" "$output"

        if ! test "${#arguments}" -eq 0; then
            printf -v test_result '%s\n\nARGUMENTS TABLE\n\n' "$test_result"
            output="$(print-arguments-table 2>&1)"
            printf -v test_result '%s%s' "$test_result" "$output"
        fi

        if ! test "${#options[@]}" -eq 0; then
            printf -v test_result '%s\n\nOPTIONS TABLE\n\n' "$test_result"
            output="$(print-options-table 2>&1)"
            printf -v test_result '%s%s' "$test_result" "$output"
        fi
    else
        printf -v test_result '%sERROR: %s' "$test_result" "$error"
    fi

    if [[ "$snaphot" != "$test_result" ]]; then
        printf ' failed!\n\nTest: %s did not match snapshot\n\n' "$test_file" >&2
        printf '%s\n\n' "$USAGE" >&2
        diff -Naurd --label='snapshot' <(printf '%s' "$snaphot") --label='test-result' <(printf '%s' "$test_result") >&2
        printf '\n'
    else
        printf ' pass.\n'
    fi
}

function run-tests {
    if ! test -z "$1"; then
        run-test "$1"
    else
        local t
        for t in tests/docopt/*.docopt; do
            run-test "$t"
        done
    fi
}

run-tests "$1"
