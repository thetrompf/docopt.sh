#!/bin/bash

function print-args {
    # shellcheck disable=SC2154
    if ! declare -p ARGS 2> /dev/null | grep -q 'declare \-A'; then
        printf 'The "ARGS" variable must be declared as an array before invoking print-args\n' >&2
        return 1
    fi

    local i

    printf 'declare -A ARGS=('
    for i in "${!ARGS[@]}"; do
        printf '\n    ["%s"]=%s\n' "$i" "${ARGS[i]}"
    done
    printf ')'
}

function build-args {
    # shellcheck disable=SC2154
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking build-args\n' >&2
        return 1
    fi
    # shellcheck disable=SC2154
    if ! declare -p arguments 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "arguments" variable must be declared as an array before invoking build-args\n' >&2
        return 1
    fi

    local arg_name arg_type arg_occurance
    local opt_short opt_long opt_default opt_occurance
    local -i i=0

    printf -- 'declare -A ARGS=('

    for ((i=0; i<${#options}; i+=_DOCOPT_OPTION_STRUCT_LENGTH)); do
        opt_short="${options[i+_DOCOPT_OPTION_POSITION_SHORT]}"
        opt_long="${options[i+_DOCOPT_OPTION_POSITION_LONG]}"

        if test -z "$opt_short" && test -z "$opt_long"; then
            continue
        fi

        opt_default="${options[i+_DOCOPT_OPTION_POSITION_DEFAULT]}"
        opt_occurance="${options[i+_DOCOPT_OPTION_POSITION_OCCURANCE]}"
        if test -z "$opt_long"; then
            if [[ "$opt_occurance" == "$_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS" ]]; then
                printf -- '\n    ["-%s"]=0\n' "$opt_short"
            elif test -z "$opt_default"; then
                printf -- '\n    ["-%s"]=false\n' "$opt_short"
            else
                printf -- '\n    ["-%s"]=''%s''\n' "$opt_short" "$opt_default"
            fi
        else
            if [[ "$opt_occurance" == "$_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS" ]]; then
                printf -- '\n    ["--%s"]=0\n' "$opt_long"
            elif test -z "$opt_default"; then
                printf -- '\n    ["--%s"]=false\n' "$opt_long"
            else
                printf -- '\n    ["--%s"]=%s\n' "$opt_long" "$opt_default"
            fi
        fi
    done

    for ((i=0; i<${#arguments}; i+=_DOCOPT_ARGUMENT_STRUCT_LENGTH)); do
        arg_name="${arguments[i+_DOCOPT_ARGUMENT_POSITION_NAME]}"
        if test -z "$arg_name"; then
            continue
        fi
        arg_type="${arguments[i+_DOCOPT_ARGUMENT_POSITION_TYPE]}"
        arg_occurance="${arguments[i+_DOCOPT_ARGUMENT_POSITION_OCCURANCE]}"

        case $arg_type in
            $_DOCOPT_PROGRAM_ARG_TYPE_POSITIONAL)
                case "$arg_occurance" in
                    $_DOCOPT_PROGRAM_OCCURANCE_ONCE)
                        printf -- '\n    ["%s"]=\n' "$arg_name";;
                    $_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS)
                        printf -- '\n    ["%s"]=\n' "$arg_name";;
                    *)
                        printf 'Unknown OCCURANCE: %s for argument: %s\n' \
                            "$arg_occurance" \
                            "$arg_name" \
                        >&2
                        return 1;;
                esac;;
            $_DOCOPT_PROGRAM_ARG_TYPE_COMMAND)
                case "$arg_occurance" in
                    $_DOCOPT_PROGRAM_OCCURANCE_ONCE)
                        printf -- '\n    ["%s"]=false\n' "$arg_name";;
                    $_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS)
                        printf -- '\n    ["%s"]=0\n' "$arg_name";;
                    *)
                        printf 'Unknown OCCURANCE: %s for argument: %s\n' \
                            "$arg_occurance" \
                            "$arg_name" \
                        >&2
                        return 1;;
                esac;;
            *)
                printf 'Unknown ARG_TYPE: %s for argument: %s\n' \
                    "$arg_type" \
                    "$arg_name" \
                >&2
                return 1;;
        esac

    done

    printf -- ')'
}

if [[ ( "$0" == "build-args.sh" ) || ( "$0" == "./build-args.sh" ) ]]; then
    options=()
    arguments=()
    build-args "$@"
fi
