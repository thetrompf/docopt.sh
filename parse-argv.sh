#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

function parse-argv {
    if ! declare -p programs 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "programs" variable must be declared as an array before invoking parse-argv\n' >&2
        return 1
    fi
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking parse-argv\n' >&2
        return 1
    fi
    if ! declare -p arguments 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "arguments" variable must be declared as an array before invoking parse-argv\n' >&2
        return 1
    fi
    if ! declare -p ARGS 2> /dev/null | grep -q 'declare \-A'; then
        printf 'The "ARGS" variable must be declared as an array before invoking parse-argv\n' >&2
        return 1
    fi

    local USAGE
    USAGE="$1"


    # shellcheck disable=SC2086
    set -- $2

    local e opt io
    for e in "$@"; do
        # printf 'arg: "%s"\n' "$e"
        if [[ $e == -[a-Z0-9]* ]]; then
            # printf -- 'short - '
            :
        fi
        if [[ $e == --[a-Z0-9_-]* ]]; then
            e="${e#--*}"
            # opt="${e%%=*}"
            arg="${e#*=}"
            index-of "$arg" options io "$_DOCOPT_OPTION_POSITION_LONG" "$_DOCOPT_OPTION_STRUCT_LENGTH"
            if [[ "$io" == '-1' ]]; then
                printf '%s' "$USAGE" >&2
                return 1
            else
                ARGS[$arg]=true
            fi
        fi
    done

    return 0
}

if [[ ( "$0" == "parse-argv.sh" ) || ( "$0" == "./parse-argv.sh" ) ]]; then
    programs=()
    options=()
    arguments=()
    parse-argv "$@"
fi
