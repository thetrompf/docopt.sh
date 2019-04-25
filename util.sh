#!/bin/bash -e

function index-of {
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

function debug-line {
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

function debug-line-single {
    local old line
    line="$1"
    if ! test -z "$DEBUG_LINE" && grep -q "$DEBUG_LINE" <<< "$line"; then
        old=$DEBUG
        DEBUG=1
        debug-line "$@"
        DEBUG=$old
    fi
}

function debug-printf {
    if [[ "$DEBUG" == "1" ]]; then
        # shellcheck disable=SC2059
        printf "$@"
    fi
}

function debug-line-printf {
    local old line
    line="$1"
    shift
    if ! test -z "$DEBUG_LINE" && grep -q "$DEBUG_LINE" <<< "$line"; then
        old=$DEBUG
        DEBUG=1
        debug-printf "$@"
        DEBUG=$old
    fi
}

function print-table-header {
    # shellcheck disable=SC2154
    if ! declare -p column_spec 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "column_spec" variable must be declared as an array before invoking print-table-header\n' >&2
        return 1
    fi

    local work line header column width i

    for ((i = 0; i < ${#column_spec[@]}; i += 2 )); do
        column="${column_spec[i]}"
        width="${column_spec[i+1]}"
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

function print-table-row {
    # shellcheck disable=SC2154
    if ! declare -p column_spec 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "column_spec" variable must be declared as an array before invoking print-table-row\n' >&2
        return 1
    fi

    local work row column width i

    for (( i = 0; i < ${#column_spec[@]}; i += 2 )); do
        column="${column_spec[i]}"
        width="${column_spec[i+1]}"
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v work -- "| % ${width}s " "$column"
        row+="$work"
    done

    printf -- '%s|\n' "$row"
}

function print-table-hr {
    if ! declare -p column_spec 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "column_spec" variable must be declared as an array before invoking print-table-hr\n' >&2
        return 1
    fi

    local work line width i

    for ((i = 0; i < ${#column_spec[@]}; i += 2 )); do
        width="${column_spec[i+1]}"
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v work -- '%0.1s' $(eval echo "-"{0..$((width + 1))});
        line+="+$work"
    done

    printf -- '%s+\n' "$line"
}

