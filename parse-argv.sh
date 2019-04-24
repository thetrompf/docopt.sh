#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

function parse-argv {
    if ! declare -p programs 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "programs" variable must be declared as an array before invoking parse-argv\n' >&2
        exit 1
    fi
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking parse-argv\n' >&2
        exit 1
    fi
    if ! declare -p arguments 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "arguments" variable must be declared as an array before invoking parse-argv\n' >&2
        exit 1
    fi

    echo "${programs[@]}"

    local e arg opt
    for e in "$@"; do
        printf 'arg: "%s"\n' "$e"
        if [[ $e == -[a-Z0-9]* ]]; then
            printf -- 'short - '
        fi
        if [[ $e == --[a-Z0-9]* ]]; then
            printf -- 'long - '
            if [[ $e == --*=* ]]; then
                arg="${e#*=}"
                opt="${e%%=*}"
                printf '%s = %s ' "$opt" "$arg"
            fi
        fi
        printf '\n\n'
    done
}

if [[ ( "$0" == "parse-argv.sh" ) || ( "$0" == "./parse-argv.sh" ) ]]; then
    programs=()
    options=()
    arguments=()
    parse-argv "$@"
fi
