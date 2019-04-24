#!/bin/bash -e

function index_of {
    local needle key
    local -i i i2 step start
    local -n haystack ret

    needle=$1
    haystack=$2
    ret=$3
    start=${4:-0}
    step=${5:-1}

    i2=-1
    for (( i=start; i<${#haystack[@]}; i+=step )); do
        i2=$(( i2 + 1 ))
        key="${haystack[i]}"
        if [[ "$key" == "$needle" ]]; then
            ret=$i2
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

function print_table_header {
    local work line header column width i
    local -n _column_spec

    _column_spec=$1
    for ((i = 0; i < ${#_column_spec[@]}; i += 2 )); do
        column="${_column_spec[i]}"
        width="${_column_spec[i+1]}"
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v work -- '%0.1s' $(eval echo "-"{0..$((width + 1))});
        line+="+$work"
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v work -- "| % ${width}s " "$column"
        header+="$work"
    done

    printf -- '%s+\n' "$line"
    printf -- '%s|\n' "$header"
    printf -- '%s+\n' "$line"
}

function print_table_row {
    local work row column width i
    local -n _column_spec

    _column_spec=$1
    for (( i = 0; i < ${#_column_spec[@]}; i += 2 )); do
        column="${_column_spec[i]}"
        width="${_column_spec[i+1]}"
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v work -- "| % ${width}s " "$column"
        row+="$work"
    done

    printf -- '%s|\n' "$row"
}

function print_table_hr {
    local work line width i
    local -n _column_spec

    _column_spec=$1
    for ((i = 0; i < ${#_column_spec[@]}; i += 2 )); do
        width="${_column_spec[i+1]}"
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v work -- '%0.1s' $(eval echo "-"{0..$((width + 1))});
        line+="+$work"
    done

    printf -- '%s+\n' "$line"
}

