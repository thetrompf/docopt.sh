#!/bin/bash

function run-test {

    local test_file snaphot_file snaphot USAGE test_result \
          output1 output2 output3 output4 output5 output6 output7 \
          error

    local -i status
    test_file=$1

    # shellcheck disable=SC1091
    source ./parse-options.sh
    # shellcheck disable=SC1091
    source ./parse-programs.sh

    USAGE="$(cat "$test_file")"
    snaphot_file="$(dirname "$test_file")/__snapshots__/$(basename "$test_file")"

    printf 'Running test: %s...' "$test_file"
    if ! test -f "$snaphot_file"; then
        printf '\nSnapshot file not found: %s\n' "$snaphot_file" >&2
        exit 1
    fi

    snaphot="$(cat "$snaphot_file")"

    # shellcheck disable=SC2034
    local -a valid_programs=() \
             positional_arguments=() \
             options=()

    printf -v output1 '%s\n\n' "$USAGE"

    parse-options "$USAGE" 'error'
    status=$?

    if test $status -eq 0; then
        parse-programs "$USAGE" 'valid_programs' 'positional_arguments' 'error'
        status=$?
    fi

    if test $status -eq 0; then
        printf -v output2 'PROGRAMS TABLE\n\n'
        output3="$(print-programs-table 'valid_programs' 'error' 2>&1)"

        if test "${#positional_arguments}" -eq 0; then
            output4=
            output5=
        else
            printf -v output4 '\n\nPOSITIONAL ARGUMENTS TABLE\n\n'
            output5="$(print-positional-arguments-table positional_arguments)"
        fi

        if test "${#options[@]}" -eq 0; then
            output6=
            output7=
        else
            printf -v output6 '\n\nOPTIONS TABLE\n\n'
            output7="$(print-options-table 2>&1)"
        fi
    else
        printf -v output2 'ERROR: %s' "$error"
    fi

    printf -v test_result '--' '%s%s%s%s%s%s%s' "$output1" "$output2" "$output3" \
                                                "$output4" "$output5" "$output6" "$output7"

    if [[ "$snaphot" != "$test_result" ]]; then
        printf ' failed!\n\nTest: %s did not match snapshot\n\n' "$test_file" >&2
        printf '%s' "$output1"
        diff -Naurd --label='snapshot' <(printf '%s' "$snaphot") --label='test-result' <(printf '%s' "$test_result") >&2
        exit 1
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
