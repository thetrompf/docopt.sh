#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

function print-programs-table {
    local -n programs
    programs=$1

    local header_program='PRG' \
          header_position='POS' \
          header_necessity='NEC' \
          header_type='TYP' \
          header_index='IDX' \
          header_occurance='OCCUR'

    local max_program=${#header_program} \
          max_position=${#header_position} \
          max_necessity=${#header_necessity} \
          max_type=${#header_type} \
          max_index=${#header_index} \
          max_occurance=${#header_occurance} \
          line line1 line2 line3 line4 line5 line6

    # shellcheck disable=SC2046 disable=SC1083
    printf -v line1 -- "%0.1s" $(eval echo "-"{0..$((max_program + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line2 -- "%0.1s" $(eval echo "-"{0..$((max_position + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line3 -- "%0.1s" $(eval echo "-"{0..$((max_necessity + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line4 -- "%0.1s" $(eval echo "-"{0..$((max_type + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line5 -- "%0.1s" $(eval echo "-"{0..$((max_index + 1))})
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line6 -- "%0.1s" $(eval echo "-"{0..$((max_occurance + 1))})
    printf -v line -- '+%s+%s+%s+%s+%s+%s+' "$line1" "$line2" "$line3" "$line4" "$line5" "$line6"

    printf -- '%s\n' "$line"
    printf -- "| % ${max_program}s | % ${max_position}s | % ${max_necessity}s | % ${max_type}s | % ${max_index}s | % ${max_occurance}s |\n" "$header_program" "$header_position" "$header_necessity" "$header_type" "$header_index" "$header_occurance"
    printf -- '%s\n' "$line"

    local -p i=0 j=-1 p=0 pi=0 programs_count=${#programs[@]}
    for (( i=0; i<programs_count; i++ )); do
        p="${programs[$i]}"
        j=$((j + 1))
        if test "$i" -eq 0 || ! ((j % 5)); then
            j=0
            if test "$p" -eq 8; then
                i=$((i + 1))
                p="${programs[$i]}"
                if test -z "$p"; then
                    continue
                fi
                pi=$((pi + 1))
                printf -- '\n%s\n' "$line"
            elif ! test "$i" -eq 0; then
                printf -- '\n'
            fi
            printf -- "| % ${max_program}s " "$pi"
            printf -- "| % ${max_position}s " "$p"
            i=$((i + 1))
            j=$((j + 1))
            p="${programs[$i]}"
        fi
        if ! test -z "$p" && ! ((j % 1)); then
            case "$p" in
                1) p="req";;
                2) p="opt";;
                *) printf 'Unknown necessity: p=%s i=%d j=%d\n' "$p" "$i" "$j" >&2; return 1;;
            esac
            printf -- "| % ${max_necessity}s " "$p"
            i=$((i + 1))
            j=$((j + 1))
            p="${programs[$i]}"
        fi
        if ! test -z "$p" && ! ((j % 2)); then
            case "$p" in
                3) p="opt";;
                4) p="pos";;
                5) p="com";;
                *) printf 'Unknown type: %s\n' "$p" >&2; return 1;;
            esac
            printf -- "| % ${max_type}s " "$p"
            i=$((i + 1))
            j=$((j + 1))
            p="${programs[$i]}"
        fi
        if ! test -z "$p" && ! ((j % 3)); then
            printf -- "| % ${max_index}s " "$p"
            i=$((i + 1));j=$((j + 1))
            p="${programs[$i]}"
        fi
        if ! test -z "$p" && ! ((j % 4)); then
            case "$p" in
                6) p="once";;
                7) p="cont";;
                *) printf 'Unknown occurance: %s\n' "$p" >&2; return 1;;
            esac
            printf -- "| % ${max_occurance}s |" "$p"
        fi

    done
    printf '\n%s' "$line"
}

function print-positional-arguments-table {
    local -n positionals
    positionals=$1

    local header_index='IDX' \
          header_name='NAME' \
          header_type='TYP' \
          header_occurance='OCCUR' \

    local max_index=${#header_index} \
          max_name=${#header_name} \
          max_type=${#header_type} \
          max_occurance=${#header_occurance} \
          line line1 line2 line3 line4

    local e i=-1 j=-2 positionals_count=0
    for e in "${!positionals[@]}"; do if test "${#e}" -gt "$max_index"; then max_index="${#e}"; fi; done
    for e in "${positionals[@]}"; do if test "${#e}" -gt "$max_name"; then max_name="${#e}"; fi; done

    # shellcheck disable=SC2046 disable=SC1083
    printf -v line1 -- "%0.1s" $(eval echo "-"{0..$((max_index + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line2 -- "%0.1s" $(eval echo "-"{0..$((max_name + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line3 -- "%0.1s" $(eval echo "-"{0..$((max_type + 1))});
    # shellcheck disable=SC2046 disable=SC1083
    printf -v line4 -- "%0.1s" $(eval echo "-"{0..$((max_occurance + 1))});
    printf -v line -- '+%s+%s+%s+%s+' "$line1" "$line2" "$line3" "$line4"

    printf -- '%s\n' "$line"
    printf -- "| % ${max_index}s | % ${max_name}s | % ${max_type}s | % ${max_occurance}s |\n" "$header_index" "$header_name" "$header_type" "$header_occurance"
    printf -- '%s\n' "$line"

    j=-1
    positionals_count=${#positionals[@]}
    for (( i=0; i<positionals_count; i++ )); do
        j=$((j + 1))
        e="${positionals[$i]}"
        printf -- "| % ${max_index}s " "$j"
        printf -- "| % ${max_name}s " "$e"
        i=$((i + 1))
        e="${positionals[$i]}"
        case "$e" in
            3) e=opt;;
            4) e=pos;;
            5) e=com;;
            *) printf 'Unknown arg type: %s' "$e" >&2; return 1;;
        esac
        printf -- "| % ${max_type}s " "$e"
        i=$((i + 1))
        e="${positionals[$i]}"
        case "$e" in
            6) e=once;;
            7) e=cont;;
            *) printf 'Unknown occurance: %s\n' "$e" >&2; return 1;;
        esac
        printf -- "| % ${max_occurance}s |\n" "$e"
    done

    printf '%s\n' "$line"
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
          short long argument option positional arg dots program_name \
          is_option=false is_short=false is_argument=false \
          parse_program=false is_program_name=false \
          is_optional=false is_continous=false \
          i=-1 io=-1 pos=0 cond_pos=0 \
          ARG_NECESSITY ARG_TYPE ARG_OCCURANCE

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
        short= long= argument= option= positional= arg= dots= program_name= \
        is_option=false is_short=false is_continous=false \
        is_argument=false is_program_name=false \
        i=-1 io=-1 pos=0 cond_pos=0

        while IFS= read -r -n1 char; do
            i=$((i + 1))
            if test -z "$char"; then continue; fi

            debug_line_printf "$line" 'io = %s\n' "$io"
            debug_line_printf "$line" 'arg = %s\n' "$arg"
            debug_line_printf "$line" 'dots = %s\n' "$dots"
            debug_line_printf "$line" 'option = %s\n' "$option"
            debug_line_printf "$line" 'is_argument = %s\n' "$is_argument"
            debug_line_printf "$line" 'is_continous = %s\n' "$is_continous"
            debug_line_printf "$line" 'is_option = %s\n' "$is_option"
            debug_line_printf "$line" '\n'
            debug_line_single "$line" "$i"

            if [[ "$char" == "." ]]; then
                dots+="$char"
                if  [[ "$dots" == '...' ]]; then
                    dots=
                    is_continous=true
                fi
                continue
            fi

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
                    # shellcheck disable=SC1007
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

                    # shellcheck disable=SC1007
                    option= # reset option variable
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))
                fi

                if ! test -z "$positional"; then
                    if [[ "$positional" =~ [a-z] ]]; then ARG_TYPE="$ARG_TYPE_COMMAND"; else ARG_TYPE="$ARG_TYPE_POSITIONAL"; fi
                    if $is_continous; then ARG_OCCURANCE="$ARG_OCCURANCE_CONTINOUS"; is_continous=false; else ARG_OCCURANCE="$ARG_OCCURANCE_ONCE"; fi
                    positionals+=( "$positional" "$ARG_TYPE" "$ARG_OCCURANCE" )
                    index_of "$positional" positionals io
                    positional=
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE" "$io" "$ARG_OCCURANCE" )
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
                    # shellcheck disable=SC1007
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

                    # shellcheck disable=SC1007
                    option= # reset option variable
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
                    pos=$((pos + 1))
                fi

                if ! test -z "$positional"; then
                    if [[ "$positional" =~ [a-z] ]]; then ARG_TYPE="$ARG_TYPE_COMMAND"; else ARG_TYPE="$ARG_TYPE_POSITIONAL"; fi
                    if $is_continous || test "$dots" -eq '...'; then ARG_OCCURANCE="$ARG_OCCURANCE_CONTINOUS"; is_continous=false; else ARG_OCCURANCE="$ARG_OCCURANCE_ONCE"; fi
                    positionals+=( "$positional" "$ARG_TYPE" "$ARG_OCCURANCE" )
                    index_of "$positional" positionals io
                    positional=
                    if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
                    programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE" "$io" "$ARG_OCCURANCE" )
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

                    # shellcheck disable=SC1007
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

            # shellcheck disable=SC1007
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
            if [[ "$positional" =~ [a-z] ]]; then ARG_TYPE="$ARG_TYPE_COMMAND"; else ARG_TYPE="$ARG_TYPE_POSITIONAL"; fi
            if $is_continous; then ARG_OCCURANCE="$ARG_OCCURANCE_CONTINOUS"; is_continous=false; dots=; else ARG_OCCURANCE="$ARG_OCCURANCE_ONCE"; fi
            positionals+=( "$positional" "$ARG_TYPE" "$ARG_OCCURANCE" )
            index_of "$positional" positionals io
            positional=
            if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
            programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE" "$io" "$ARG_OCCURANCE" )
            pos=$((pos + 1))
        fi

        if ! test -z "$program_name"; then
            programs+=( "$END_OF_PROGRAM" )
        fi

    done <<< "$USAGE"
}
