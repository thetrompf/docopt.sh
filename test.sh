#!/bin/bash

# shellcheck disable=SC1091
source ./parse-options.sh
source ./parse-programs.sh

function run-test {
    local test_file snaphot_file snaphot USAGE test_result \
          output1 output2 output3 output4 output5 output6 output7
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
    local -a valid_programs=() \
             positional_arguments=() \
             option_shorts=() \
             option_longs=() \
             option_arguments=() \
             option_defaults=()

    parse-options "$USAGE" option_shorts option_longs option_arguments option_defaults
    parse-programs "$USAGE" valid_programs positional_arguments option_shorts option_longs option_arguments option_defaults

    printf -v output1 '%s\n\n' "$USAGE"
    printf -v output2 'PROGRAMS TABLE\n\n'
    output3="$(print-programs-table valid_programs option_shorts option_longs option_arguments option_defaults)"

    if test "${#positional_arguments}" -eq 0; then
        output4=
        output5=
    else
        printf -v output4 '\n\nPOSITIONAL ARGUMENTS TABLE\n\n'
        output5="$(print-positional-arguments-table positional_arguments)"
    fi

    if test "${#option_longs}" -eq 0; then
        output6=
        output7=
    else
        printf -v output6 '\n\nOPTIONS TABLE\n\n'
        output7="$(print-options-table option_shorts option_longs option_arguments option_defaults)"
    fi
    printf -v test_result '--' '%s%s%s%s%s%s%s' "$output1" "$output2" "$output3" \
                                                "$output4" "$output5" "$output6" "$output7"

    if [[ "$snaphot" != "$test_result" ]]; then
        printf ' failed!\n\nTest: %s did not match snapshot\n\n' "$test_file"
        printf 'Expected:\n%s\n\n' "$snaphot"
        printf 'Got:\n%s\n' "$test_result"
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
        for t in tests/*.docopt; do
            run-test "$t"
        done
    fi
}

run-tests "$1"
