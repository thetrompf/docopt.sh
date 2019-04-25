#!/bin/bash -e
# shellcheck disable=SC1091
source ./util.sh

# PROGRAMS STRUCTURE [
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
# positional  4 [index in arguments]
# command     5 [index in arguments]
#
# ARG OCCURANCES
# once        6
# continous   7
#
# EOP         EOP

# ARGUMENTS STRUCTURE [
#    (name, type, occurance)
#    ...
#]

function print-programs-table {
    if ! declare -p programs 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "programs" variable must be declared as an array before invoking print-programs-table\n' >&2
        return 1
    fi

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
          wline line='+'

    for wline in $max_program $max_position $max_necessity $max_type $max_index $max_occurance; do
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v wline -- "%0.1s" $(eval echo "-"{0..$((wline + 1))});
        printf -v line -- '%s%s+' "$line" "$wline"
    done

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

function print-arguments-table {
    if ! declare -p arguments 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "arguments" variable must be declared as an array before invoking print-arguments-table\n' >&2
        return 1
    fi

    local header_index='IDX' \
          header_name='NAME' \
          header_type='TYP' \
          header_occurance='OCCUR'

    local max_index=${#header_index} \
          max_name=${#header_name} \
          max_type=${#header_type} \
          max_occurance=${#header_occurance} \
          wline line='+'

    local e i=-1 j=-2 arguments_count=0
    for e in "${!arguments[@]}"; do if test "${#e}" -gt "$max_index"; then max_index="${#e}"; fi; done
    for e in "${arguments[@]}"; do if test "${#e}" -gt "$max_name"; then max_name="${#e}"; fi; done

    for wline in $max_index $max_name $max_type $max_occurance; do
        # shellcheck disable=SC2046 disable=SC1083 disable=SC2175
        printf -v wline -- "%0.1s" $(eval echo "-"{0..$((wline + 1))});
        printf -v line -- '%s%s+' "$line" "$wline"
    done

    printf -- '%s\n' "$line"
    printf -- "| % ${max_index}s | % ${max_name}s | % ${max_type}s | % ${max_occurance}s |\n" "$header_index" "$header_name" "$header_type" "$header_occurance"
    printf -- '%s\n' "$line"

    j=-1
    arguments_count=${#arguments[@]}
    for (( i=0; i<arguments_count; i++ )); do
        j=$((j + 1))
        e="${arguments[$i]}"
        printf -- "| % ${max_index}s " "$j"
        printf -- "| % ${max_name}s " "$e"
        i=$((i + 1))
        e="${arguments[$i]}"
        case "$e" in
            3) e=opt;;
            4) e=pos;;
            5) e=com;;
            *) printf 'Unknown arg type: %s' "$e" >&2; return 1;;
        esac
        printf -- "| % ${max_type}s " "$e"
        i=$((i + 1))
        e="${arguments[$i]}"
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
    if ! declare -p programs 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "programs" variable must be declared as an array before invoking parse-programs\n' >&2
        return 1
    fi
    if ! declare -p arguments 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "arguments" variable must be declared as an array before invoking parse-programs\n' >&2
        return 1
    fi
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking parse-programs\n' >&2
        return 1
    fi

    local -n err

    local    USAGE line char \
             argument option option_argument ellipsis program_name \
             is_option=false is_short=false is_option_argument=false \
             parse_program=false is_program_name=false \
             is_optional=false is_continous=false \
             i=-1 io=-1 pos=0 \
             exit_code=0 \
             ARG_NECESSITY ARG_TYPE ARG_OCCURANCE

    USAGE=$1 \
    err=$2

    function assign-argument {
        if [[ "$argument" =~ ^(\<[a-z0-9_-]+\>|[A-Z0-9_-]+)$ ]]; then ARG_TYPE="$_DOCOPT_PROGRAM_ARG_TYPE_POSITIONAL"; else ARG_TYPE="$_DOCOPT_PROGRAM_ARG_TYPE_COMMAND"; fi
        if $is_continous || [[ "$ellipsis" == '...' ]]; then ARG_OCCURANCE="$_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS"; is_continous=false; else ARG_OCCURANCE="$_DOCOPT_PROGRAM_OCCURANCE_ONCE"; fi
        index-of "$argument" arguments io "$_DOCOPT_ARGUMENT_POSITION_NAME" "$_DOCOPT_ARGUMENT_STRUCT_LENGTH"
        if test $io -eq -1; then
            arguments+=( "$argument" "$ARG_TYPE" "$ARG_OCCURANCE" )
            index-of "$argument" arguments io "$_DOCOPT_ARGUMENT_POSITION_NAME" "$_DOCOPT_ARGUMENT_STRUCT_LENGTH"
        else
            arguments[(io * $_DOCOPT_ARGUMENT_STRUCT_LENGTH) + $_DOCOPT_ARGUMENT_POSITION_OCCURANCE]="$_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS"
        fi
        argument=
        if $is_optional; then ARG_NECESSITY="$_DOCOPT_PROGRAM_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$_DOCOPT_PROGRAM_NECESSITY_REQUIRED"; fi
        programs+=( "$pos" "$ARG_NECESSITY" "$ARG_TYPE" "$io" "$ARG_OCCURANCE" )
        pos=$((pos + 1))
        is_continous=false
    }

    function assign-option {
        # [-o ]
        # [--option ]
        # [--option=]

        if $is_short; then
            index-of "$option" options io "$_DOCOPT_OPTION_POSITION_SHORT" "$_DOCOPT_OPTION_STRUCT_LENGTH"
            if test $io -eq -1; then
                # short long type default occurance
                options+=( "$option" "" "" "" "$_DOCOPT_PROGRAM_OCCURANCE_ONCE" )
                index-of "$option" options io "$_DOCOPT_OPTION_POSITION_SHORT" "$_DOCOPT_OPTION_STRUCT_LENGTH"
            else
                is_option_argument=true
            fi
        else
            index-of "$option" options io "$_DOCOPT_OPTION_POSITION_LONG" "$_DOCOPT_OPTION_STRUCT_LENGTH"
            if test $io -eq -1; then
                # short long type default occurance
                options+=( "" "$option" "" "" "$_DOCOPT_PROGRAM_OCCURANCE_ONCE" )
                index-of "$option" options io "$_DOCOPT_OPTION_POSITION_LONG" "$_DOCOPT_OPTION_STRUCT_LENGTH"
            else
                is_option_argument=true
            fi
        fi

        # shellcheck disable=SC1007

        if $is_continous; then ARG_OCCURANCE="$_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS"; else ARG_OCCURANCE="$_DOCOPT_PROGRAM_OCCURANCE_ONCE"; fi
        if $is_optional; then ARG_NECESSITY="$_DOCOPT_PROGRAM_NECESSITY_OPTIONAL"; else ARG_NECESSITY="$_DOCOPT_PROGRAM_NECESSITY_REQUIRED"; fi

        options[(io * $_DOCOPT_OPTION_STRUCT_LENGTH) + $_DOCOPT_OPTION_POSITION_OCCURANCE]="$ARG_OCCURANCE"
        programs+=( "$pos" "$ARG_NECESSITY" "$_DOCOPT_PROGRAM_ARG_TYPE_OPTION" "$io" "$ARG_OCCURANCE" )

        pos=$((pos + 1))
        is_continous=false
        option= # reset option variable
    }

    function assign-option-argument {
        # [-o ARG ]
        # [-o=ARG ]
        # [--option ARG ]
        # [--option=ARG ]

        if ! test -z "${options[io+_DOCOPT_OPTION_POSITION_ARGUMENT]}" && [[ "${options[io+_DOCOPT_OPTION_POSITION_ARGUMENT]}" != "$option_argument" ]]; then
            printf -v err -- 'Argument: %s should match %s in option %s %s' "$option_argument" "${options[io+_DOCOPT_OPTION_POSITION_ARGUMENT]}" "${options[io+_DOCOPT_OPTION_POSITION_LONG]}" "${options[io+_DOCOPT_OPTION_POSITION_SHORT]}"
            exit_code=1
            return 0
        fi

        options[(io * $_DOCOPT_OPTION_STRUCT_LENGTH) + $_DOCOPT_OPTION_POSITION_ARGUMENT]="$option_argument"
        if $is_continous; then
            options[(io * $_DOCOPT_OPTION_STRUCT_LENGTH) + $_DOCOPT_OPTION_POSITION_OCCURANCE]="$_DOCOPT_PROGRAM_OCCURANCE_CONTINOUS"
        fi

        # shellcheck disable=SC1007
        option_argument= # reset arg variable
        is_continous=false
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
        argument= option= option_argument= ellipsis= program_name= \
        is_option=false is_short=false is_continous=false \
        is_option_argument=false is_program_name=false \
        i=-1 io=-1 pos=0

        while IFS= read -r -n1 char; do
            if ! test $exit_code -eq 0; then break 2; fi

            i=$((i + 1))
            if test -z "$char"; then continue; fi

            debug-line-printf "$line" 'io                  = %s\n' "$io"
            debug-line-printf "$line" 'ellipsis            = %s\n' "$ellipsis"
            debug-line-printf "$line" 'argument            = %s\n' "$argument"
            debug-line-printf "$line" 'option              = %s\n' "$option"
            debug-line-printf "$line" 'option_argument     = %s\n' "$option_argument"
            debug-line-printf "$line" 'is_option_argument  = %s\n' "$is_option_argument"
            debug-line-printf "$line" 'is_continous        = %s\n' "$is_continous"
            debug-line-printf "$line" 'is_option           = %s\n' "$is_option"
            debug-line-printf "$line" '\n'
            debug-line-single "$line" "$i"

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
                if ! test -z "$option_argument"; then
                    assign-option-argument
                fi

                if ! test -z "$option"; then
                    assign-option
                fi

                if ! test -z "$argument"; then
                    assign-argument
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

                is_option_argument=false

                if ! test -z "$option_argument"; then
                    assign-option-argument
                fi

                if ! test -z "$option"; then
                    assign-option
                fi

                if ! test -z "$argument"; then
                    assign-argument
                fi

                is_option=false
                is_short=false
                continue
            fi

            if [[ "$char" == "-" ]]; then
                # [-]
                # [--]...

                if $is_option_argument && ! test -z "$option_argument"; then
                    # [-o=ARGU-MENT]
                    # [-o ARGU-MENT]
                    # [--option=ARGU-MENT]
                    # [--option ARGU-MENT]
                    option_argument+="$char"
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


                if test -z "$option_argument"; then
                    # if no agument has been found for current option
                    is_option_argument=true
                fi

                is_option=false
                is_short=false
                continue
            fi

            if $is_program_name; then
                program_name+="$char"
            fi

            if $is_option_argument; then
                option_argument+="$char"
            fi

            if $is_option; then
                option+="$char"
            fi

            if ! $is_program_name && ! $is_option_argument && ! $is_option && $parse_program && ! test -z "$program_name"; then
                argument+="$char"
            fi

        done <<< "$line"

        if $is_option && ! test -z "$option"; then
            assign-option
        fi

        if $is_option_argument && ! test -z "$option_argument"; then
            assign-option-argument
        fi

        if ! test -z "$argument"; then
            assign-argument
        fi

        if ! test -z "$program_name"; then
            programs+=( "$_DOCOPT_END_OF_PROGRAM" )
        fi

    done <<< "$USAGE"

    return $exit_code
}
