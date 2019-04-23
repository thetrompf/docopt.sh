#!/bin/bash -e

USAGE=$(cat <<-'DOC'
Usage:
    program --or | --nor
    program --input=FILE --output=DIR
    program --destroy [POSITION]
    program create --yes USERNAME [PW]
    program --version

Options:
    -i FILE --input FILE   Input file to program. [default: -]
    -o DIR --output=DIR    Output directory to put stuff. [default: -]
    -s STR, --str STR      Some string.
    -k=<inte-ger> --kint   INTEGERS. [default: 10]
    --version              Show the version of the program.
    -h --help              Show this screen.

DOC
)

function usage {
    local status
    status="${1:-1}"

    printf '%s\n' "$USAGE"
    exit "$status"
}

# shellcheck disable=SC1091
source ./parse-programs.sh
# shellcheck disable=SC1091
source ./parse-options.sh

# shellcheck disable=SC2034
valid_programs=()
# shellcheck disable=SC2034
positional_arguments=()
# shellcheck disable=SC2034
options=()

parse-options "$USAGE" options
parse-programs "$USAGE" 'valid_programs' 'positional_arguments' 'options'

printf '\n%s\n\n\nPROGRAMS TABLE\n' "$USAGE"
print-programs-table 'valid_programs' 'options'

printf '\n\nOPTIONS TABLE\n\n'
print-options-table 'options'
