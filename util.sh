#!/bin/bash -e

function index_of {
    local needle key
    local -p i=-1
    local -n haystack ret

    needle=$1
    haystack=$2
    ret=$3

    for key in "${haystack[@]}"; do
        i=$((i + 1))
        if [[ "$key" == "$needle" ]]; then
            ret=$i
            return 0
        fi
    done

    # shellcheck disable=SC2034
    ret=-1
    return 0
}

function debug_line {
    if [[ "$DEBUG" == "1" ]]; then
        local line i c
        line="$1"
        i="$2"
        c="${3:-^}"

        printf '%s\n' "$line"
        if ! test -z "$i"; then
            printf "% $((i + 1))s%s\n" "$c"
        fi
    fi
}

function debug_line_single {
    local old line
    line="$1"
    if ! test -z "$DEBUG_LINE" && grep -q "$DEBUG_LINE" <<< "$line"; then
        old=$DEBUG
        DEBUG=1
        debug_line "$@"
        DEBUG=$old
    fi
}

function debug_printf {
    if [[ "$DEBUG" == "1" ]]; then
        # shellcheck disable=SC2059
        printf "$@"
    fi
}

function debug_line_printf {
    local old line
    line="$1"
    shift
    if ! test -z "$DEBUG_LINE" && grep -q "$DEBUG_LINE" <<< "$line"; then
        old=$DEBUG
        DEBUG=1
        debug_printf "$@"
        DEBUG=$old
    fi
}
