#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

function parse-argv {
    local e

    for e in "$@"; do
        printf 'arg: %s\n' "$e"
    done
}

if [[ "$0" == "./parse-argv.sh" ]]; then
    programs=()
    arguments=()
    parse-argv "$@"
fi
