#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

function print-programs-table {
    local -n programs
    programs=$1

    local -p i=0 p=0
    printf '[\n'
    for p in "${programs[@]}"; do
        if test $i -eq 0 || ! ((i % 5)); then
            if ! test $i -eq 0; then
                printf '),\n'
            fi
            printf '    (%d' "$p"
            if [[ "$p" != 8 ]]; then
                i=$((i + 1))
            fi
            continue
        fi
        i=$((i + 1))
        printf ',%d' "$p"
    done
    printf '),\n]\n'
}

# PROGRAM ARG STRUCTURE [
#    (position, necessity, type, index, occurances),
#    (position, necessity, type, index, occurances),
#    (position, necessity, type, index, occurances),
#    ...
#    (EOP)
#    (position, necessity, type, index, occurances),
# ]

# ARG TOKEN POSITION
# position    *
#
# ARG NECESSITY
# required    1
# optional    2
#
# ARG TYPE
# option      3 [index]
# positional  4 [index]
# command     5 [index]
#
# ARG OCCURANCES
# once        6
# continous   7
#
# EOP         8

function parse-programs {
    local ARG_NECESSITY_REQUIRED=1 \
          ARG_NECESSITY_OPTIONAL=2 \
          ARG_TYPE_OPTION=3 \
          ARG_TYPE_POSITIONAL=4 \
          ARG_TYPE_COMMAND=5 \
          ARG_OCCURANCE_ONCE=6 \
          ARG_OCCURANCE_CONTINOUS=7 \
          END_OF_PROGRAM=8

    local -n programs positionals shorts longs arguments defaults

    local USAGE line char \
          short long argument option positional arg program_name \
          is_option=false is_short=false is_argument=false \
          parse_program=false is_program_name=false \
          is_optional=false \
          i=-1 io=-1 pos=0 ARG_NECESSITY

    USAGE=$1
    programs=$2
    positionals=$3
    shorts=$4
    longs=$5
    arguments=$6
    defaults=$7

    while IFS= read -r line; do
        if $parse_program || grep -qi 'usage' <<< "$line"; then
            parse_program=true
        else
            continue
        fi

        if $parse_program && test -z "$line"; then
            parse_program=false
            break
        fi

        # shellcheck disable=SC1007 disable=SC2034
        short= long= argument= option= positional= arg= program_name= \
        is_option=false is_short=false \
        is_argument=false is_program_name=false \
        i=-1 io=-1 pos=0

        while IFS= read -r -n1 char; do
            i=$((i + 1))
            if test -z "$char"; then continue; fi

            debug_line_printf "$line" 'io = %s\n' "$io"
            debug_line_printf "$line" 'arg = %s\n' "$arg"
            debug_line_printf "$line" 'option = %s\n' "$option"
            debug_line_printf "$line" 'is_argument = %s\n' "$is_argument"
            debug_line_printf "$line" 'is_option = %s\n' "$is_option"
            debug_line_printf "$line" '\n'
            debug_line_single "$line" "$i"

            if [[ "$char" == "|" ]]; then
                pos=$((pos - 1))
                continue
            fi

            if [[ "$char" == "[" ]]; then
                is_optional=true
                continue
            fi

            if [[ "$char" == "]" ]]; then
                if ! test -z "$arg"; then
                    # [-o ARG ]
                    # [-o=ARG ]
                    # [--option ARG ]
                    # [--option=ARG ]

                    if ! test -z "${arguments[$io]}" && [[ "${arguments[$io]}" != "$arg" ]]; then
                        printf 'Argument: %s should match %s in option %s %s\n' "$arg" "${arguments[$io]}" "${longs[$io]}" "${shorts[$io]}" >&2
                        return 1
                    fi

                    arguments[$io]="$arg"
                    arg= # reset arg variable
                fi

                if ! test -z "$option"; then
                    # [-o ]
                    # [--option ]
                    if $is_short; then
                        # [-o ]
                        index_of "$option" shorts io
                        if test $io -eq -1; then
                            shorts+=( "$option" )
                            longs+=( "" )
                            arguments+=( "" )
                            defaults+=( "" )
                            index_of "$option" shorts io
                        else
                            if ! test -z "${arguments[$i]}"; then
                                is_argument=true
                            fi
                        fi

                    else
                        # [--option ]
                        index_of "$option" longs io
                        if test $io -eq -1; then
                            shorts+=( "" )
                            longs+=( "$option" )
                            arguments+=( "" )
                            defaults+=( "" )
                            index_of "$option" longs io
                        else
                            if ! test -z "${arguments[$i]}"; then
                                is_argument=true
                            fi
                        fi
                    fi

                    option= # reset option variable
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))
                fi

                if ! test -z "$positional"; then
                    positionals+=( "$positional" )
                    index_of "$positional" positionals io
                    positional=
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_POSITIONAL" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))
                fi

                is_optional=false
                continue
            fi

            if [[ "$char" == " " ]]; then
                # [-o ]
                # [-o  ]
                # [-o ARG ]
                # [-o=ARG ]
                # [--option ]
                # [--option ARG ]
                # [--option=ARG ]

                if test -z "$program_name"; then
                    is_program_name=true
                    continue
                else
                    is_program_name=false
                fi

                is_argument=false

                if ! test -z "$arg"; then
                    # [-o ARG ]
                    # [-o=ARG ]
                    # [--option ARG ]
                    # [--option=ARG ]

                    if ! test -z "${arguments[$io]}" && [[ "${arguments[$io]}" != "$arg" ]]; then
                        printf 'Argument: %s should match %s in option %s %s\n' "$arg" "${arguments[$io]}" "${longs[$io]}" "${shorts[$io]}" >&2
                        return 1
                    fi

                    arguments[$io]="$arg"
                    arg= # reset arg variable
                fi

                if ! test -z "$option"; then
                    # [-o ]
                    # [--option ]
                    if $is_short; then
                        # [-o ]
                        index_of "$option" shorts io
                        if test $io -eq -1; then
                            shorts+=( "$option" )
                            longs+=( "" )
                            arguments+=( "" )
                            defaults+=( "" )
                            index_of "$option" shorts io
                        else
                            if ! test -z "${arguments[$i]}"; then
                                is_argument=true
                            fi
                        fi

                    else
                        # [--option ]
                        index_of "$option" longs io
                        if test $io -eq -1; then
                            shorts+=( "" )
                            longs+=( "$option" )
                            arguments+=( "" )
                            defaults+=( "" )
                            index_of "$option" longs io
                        else
                            if ! test -z "${arguments[$i]}"; then
                                is_argument=true
                            fi
                        fi
                    fi

                    option= # reset option variable
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))
                fi

                if ! test -z "$positional"; then
                    positionals+=( "$positional" )
                    index_of "$positional" positionals io
                    positional=
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_POSITIONAL" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))
                fi

                is_option=false
                is_short=false
                continue
            fi

            if [[ "$char" == "-" ]]; then
                # [-]
                # [--]...

                if $is_argument && ! test -z "$arg"; then
                    # [-o=ARGU-MENT]
                    # [-o ARGU-MENT]
                    # [--option=ARGU-MENT]
                    # [--option ARGU-MENT]
                    arg+="$char"
                    # argument="$arg"
                    continue
                fi

                if $is_option && ! $is_short; then
                    # [--*-]
                    option+="$char"
                    continue
                fi

                if $is_option && $is_short; then
                    # [--]
                    is_short=false
                else
                    # [-]
                    is_short=true
                fi

                # [-]
                # [--]
                is_option=true
                continue
            fi

            if [[ "$char" == "=" ]]; then
                if $is_option && ! test -z "$option"; then
                    # [-o=]
                    # [--option=]
                    if $is_short; then
                        index_of "$option" shorts io
                        if test $io -eq -1; then
                            shorts+=( "$option" )
                            longs+=( "" )
                            arguments+=( "" )
                            defaults+=( "" )
                            index_of "$option" shorts io
                        fi
                        is_argument=true
                    else
                        index_of "$option" longs io
                        if test $io -eq -1; then
                            shorts+=( "" )
                            longs+=( "$option" )
                            arguments+=( "" )
                            defaults+=( "" )
                            index_of "$option" longs io
                        fi
                        is_argument=true
                    fi
                    option= # reset option variable
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))

                fi

                if test -z "$arg"; then
                    # if no agument has been found for current option
                    is_argument=true
                fi

                is_option=false
                is_short=false
                continue
            fi

            if $is_program_name; then
                program_name+="$char"
            fi

            if $is_argument; then
                arg+="$char"
            fi

            if $is_option; then
                option+="$char"
            fi

            if ! $is_program_name && ! $is_argument && ! $is_option && $parse_program && ! test -z "$program_name"; then
                positional+="$char"
            fi

        done <<< "$line"

        if $is_option && ! test -z "$option"; then
            # [-o=]
            # [--option=]
            if $is_short; then
                index_of "$option" shorts io
                if test $io -eq -1; then
                    shorts+=( "$option" )
                    longs+=( "" )
                    arguments+=( "" )
                    defaults+=( "" )
                    index_of "$option" shorts io
                fi
            else
                index_of "$option" longs io
                if test $io -eq -1; then
                    shorts+=( "" )
                    longs+=( "$option" )
                    arguments+=( "" )
                    defaults+=( "" )
                    index_of "$option" longs io
                fi
            fi
            option= # reset option variable
            if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
            programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
            pos=$((pos + 1))
        fi

        if $is_argument && ! test -z "$arg"; then
            if ! test -z "${arguments[$io]}" && [[ "${arguments[$io]}" != "$arg" ]]; then
                printf 'Argument: %s should match %s in option %s %s\n' "$arg" "${arguments[$io]}" "${longs[$io]}" "${shorts[$io]}" >&2
                return 1
            fi
            arguments[$io]="$arg"
            arg=
        fi

        if ! test -z "$positional"; then
            positionals+=( "$positional" )
            index_of "$positional" positionals io
            positional=
            if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
            programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_POSITIONAL" "$io" "$ARG_OCCURANCE_ONCE" )
            pos=$((pos + 1))
        fi

        if ! test -z "$program_name"; then
            programs+=( "$END_OF_PROGRAM" )
        fi

    done <<< "$USAGE"
}
