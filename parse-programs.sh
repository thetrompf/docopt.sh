#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

# PROGRAM ARG STRUCTURE [
#    (position, necessity, type, index, occurances),
#    (position, necessity, type, index, occurances),
#    (position, necessity, type, index, occurances),
#    ...
#    (EOP)
#    (position, necessity, type, index, occurances),
# ]
#
# ARG POSITION
# position    *
#
# ARG NECESSITY
# required    1
# optional    2
#
# ARG TYPE
# option      3 [index in options]
# positional  4 [index in positionals]
# command     5 [index in positionals]
#
# ARG OCCURANCES
# once        6
# continous   7
#
# EOP         EOP

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

    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line1 -- "%0.1s" $(eval echo "-"{0..$((max_program + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line2 -- "%0.1s" $(eval echo "-"{0..$((max_position + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line3 -- "%0.1s" $(eval echo "-"{0..$((max_necessity + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line4 -- "%0.1s" $(eval echo "-"{0..$((max_type + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line5 -- "%0.1s" $(eval echo "-"{0..$((max_index + 1))})
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line6 -- "%0.1s" $(eval echo "-"{0..$((max_occurance + 1))})
    printf -v line -- '+%s+%s+%s+%s+%s+%s+' "$line1" "$line2" "$line3" "$line4" "$line5" "$line6"

    printf -- '%s\n' "$line"
    printf -- "| % ${max_program}s | % ${max_position}s | % ${max_necessity}s | % ${max_type}s | % ${max_index}s | % ${max_occurance}s |\n" "$header_program" "$header_position" "$header_necessity" "$header_type" "$header_index" "$header_occurance"
    printf -- '%s\n' "$line"

    local -p i=0 j=-1 pi=0 programs_count=0 p
    programs_count=${#programs[@]}
    for (( i=0; i<programs_count; i++ )); do
        p="${programs[i]}"
        j=$((j + 1))
        if test "$i" -eq 0 || ! ((j % 5)); then
            j=0
            if [[ "$p" == "EOP" ]]; then
                i=$((i + 1))
                p="${programs[i]}"
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
            p="${programs[i]}"
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
            p="${programs[i]}"
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
            p="${programs[i]}"
        fi
        if ! test -z "$p" && ! ((j % 3)); then
            printf -- "| % ${max_index}s " "$p"
            i=$((i + 1));j=$((j + 1))
            p="${programs[i]}"
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

    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line1 -- "%0.1s" $(eval echo "-"{0..$((max_index + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line2 -- "%0.1s" $(eval echo "-"{0..$((max_name + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
    printf -v line3 -- "%0.1s" $(eval echo "-"{0..$((max_type + 1))});
    # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
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

function parse-programs {
    # shellcheck disable=SC2154
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking parse-programs\n' >&2
        return 1
    fi

    local    ARG_NECESSITY_REQUIRED=1 \
             ARG_NECESSITY_OPTIONAL=2 \
             ARG_TYPE_OPTION=3 \
             ARG_TYPE_POSITIONAL=4 \
             ARG_TYPE_COMMAND=5 \
             ARG_OCCURANCE_ONCE=6 \
             ARG_OCCURANCE_CONTINOUS=7 \
             END_OF_PROGRAM="EOP"

    local    POS_SHORT=0 \
             POS_LONG=1 \
             POS_ARGUMENT=2 \
             POS_DEFAULT=3

    local -n programs \
             positionals \
             err

    local    USAGE line char \
             short long argument option positional arg ellipsis program_name \
             is_option=false is_short=false is_argument=false \
             parse_program=false is_program_name=false \
             is_optional=false is_continous=false \
             i=-1 io=-1 pos=0 \
             exit_code=0 \
             ARG_NECESSITY ARG_TYPE ARG_OCCURANCE

    USAGE=$1 \
    programs=$2 \
    positionals=$3 \
    err=$4

    function assign-positional {
        if [[ "$positional" =~ ^(\<[a-z0-9_-]+\>|[A-Z0-9_-]+)$ ]]; then ARG_TYPE="$ARG_TYPE_POSITIONAL"; else ARG_TYPE="$ARG_TYPE_COMMAND"; fi
        if $is_continous || [[ "$ellipsis" == '...' ]]; then ARG_OCCURANCE="$ARG_OCCURANCE_CONTINOUS"; is_continous=false; else ARG_OCCURANCE="$ARG_OCCURANCE_ONCE"; fi
        index_of "$positional" positionals io 0 3
        if test $io -eq -1; then
            positionals+=( "$positional" "$ARG_TYPE" "$ARG_OCCURANCE" )
            index_of "$positional" positionals io 0 3
        else
            positionals[(io * 3) + 2]="$ARG_OCCURANCE_CONTINOUS"
        fi
        positional=
        if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
        programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE" "$io" "$ARG_OCCURANCE" )
        pos=$((pos + 1))
    }

    function assign-option {
        # [-o ]
        # [--option ]
        # [--option=]
        if $is_short; then
            index_of "$option" options io $POS_SHORT 4
            if test $io -eq -1; then
                # short long arg default
                options+=( "$option" "" "" "" )
                index_of "$option" options io $POS_SHORT 4
            else
                is_argument=true
            fi
        else
            index_of "$option" options io $POS_LONG 4
            if test $io -eq -1; then
                # short long arg default
                options+=( "" "$option" "" "" )
                index_of "$option" options io $POS_LONG 4
            else
                is_argument=true
            fi
        fi

        # shellcheck disable=SC1007
        option= # reset option variable
        if $is_optional; then ARG_NECESSITY="$ARG_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$ARG_NECESSITY_REQUIRED"; fi
        programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE_ONCE" )
        pos=$((pos + 1))
    }

    function assign-argument {
        # [-o ARG ]
        # [-o=ARG ]
        # [--option ARG ]
        # [--option=ARG ]

        if ! test -z "${options[io+POS_ARGUMENT]}" && [[ "${options[io+POS_ARGUMENT]}" != "$arg" ]]; then
            printf -v err -- 'Argument: %s should match %s in option %s %s' "$arg" "${options[io+POS_ARGUMENT]}" "${options[io+POS_LONG]}" "${options[io+POS_SHORT]}"
            exit_code=1
            return 0
        fi

        options[(io * 4) + 2]="$arg"
        # shellcheck disable=SC1007
        arg= # reset arg variable
    }

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
        short= long= argument= option= positional= arg= ellipsis= program_name= \
        is_option=false is_short=false is_continous=false \
        is_argument=false is_program_name=false \
        i=-1 io=-1 pos=0

        while IFS= read -r -n1 char; do
            if ! test $exit_code -eq 0; then break 2; fi

            i=$((i + 1))
            if test -z "$char"; then continue; fi

            debug_line_printf "$line" 'io           = %s\n' "$io"
            debug_line_printf "$line" 'arg          = %s\n' "$arg"
            debug_line_printf "$line" 'ellipsis     = %s\n' "$ellipsis"
            debug_line_printf "$line" 'option       = %s\n' "$option"
            debug_line_printf "$line" 'positional   = %s\n' "$positional"
            debug_line_printf "$line" 'is_argument  = %s\n' "$is_argument"
            debug_line_printf "$line" 'is_continous = %s\n' "$is_continous"
            debug_line_printf "$line" 'is_option    = %s\n' "$is_option"
            debug_line_printf "$line" '\n'
            debug_line_single "$line" "$i"

            if [[ "$char" == "." ]]; then
                ellipsis+="$char"
                if  [[ "$ellipsis" == '...' ]]; then
                    ellipsis=
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
                    assign-argument
                fi

                if ! test -z "$option"; then
                    assign-option
                fi

                if ! test -z "$positional"; then
                    assign-positional
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
                    assign-argument
                fi

                if ! test -z "$option"; then
                    assign-option
                fi

                if ! test -z "$positional"; then
                    assign-positional
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
                    if $is_short; then
                        # shellcheck disable=SC2034
                        printf -v err 'Equal sign between option and argument is only allowed for long options'
                        exit_code=1
                        continue
                    fi
                    assign-option
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
            assign-option
        fi

        if $is_argument && ! test -z "$arg"; then
            assign-argument
        fi

        if ! test -z "$positional"; then
            assign-positional
        fi

        if ! test -z "$program_name"; then
            programs+=( "$END_OF_PROGRAM" )
        fi

    done <<< "$USAGE"

    return $exit_code
}
