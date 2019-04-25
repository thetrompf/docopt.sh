#!/bin/bash -e
# shellcheck disable=SC1091
source ./util.sh

# OPTION ARR STRUCTURE [
#    (short, long, argument, default)
#    ...
# ]
function print-options-table {
    # structure (short, long, argument, default)
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking print-options-table\n' >&2
        return 1
    fi

    local header_idx='IDX' \
          header_short='SHORT' \
          header_long='LONG' \
          header_argument='ARG' \
          header_default='DEFAULT' \
          header_occurance='OCCUR' \

    local width_idx=${#header_idx} \
          width_short=${#header_short} \
          width_long=${#header_long} \
          width_argument=${#header_argument} \
          width_default=${#header_default} \
          width_occurance=${#header_occurance}

    local e i=0
    for (( i=0; i<${#options[@]}; i+=_DOCOPT_OPTION_STRUCT_LENGTH )); do
        e=$(( i / _DOCOPT_OPTION_STRUCT_LENGTH ));           if (( ${#e} > width_idx )); then width_idx=${#e}; fi
        e="${options[i+_DOCOPT_OPTION_POSITION_SHORT]}";     if (( ${#e} > width_short )); then width_short=${#e}; fi
        e="${options[i+_DOCOPT_OPTION_POSITION_LONG]}";      if (( ${#e} > width_long )); then width_long=${#e}; fi;
        e="${options[i+_DOCOPT_OPTION_POSITION_ARGUMENT]}";  if (( ${#e} > width_argument )); then width_argument=${#e}; fi;
        e="${options[i+_DOCOPT_OPTION_POSITION_DEFAULT]}";   if (( ${#e} > width_default )); then width_default=${#e}; fi;
        e="${options[i+_DOCOPT_OPTION_POSITION_OCCURANCE]}"; if (( ${#e} > width_occurance )); then width_occurance=${#e}; fi;
    done

    local -a column_spec=( \
        "$header_idx"       "$width_idx" \
        "$header_short"     "$width_short" \
        "$header_long"      "$width_long" \
        "$header_argument"  "$width_argument" \
        "$header_default"   "$width_default" \
        "$header_occurance" "$width_occurance"
    )

    print-table-header

    for (( i=0; i<${#options[@]}; i+=_DOCOPT_OPTION_STRUCT_LENGTH )); do
        column_spec[0]=$(( i / _DOCOPT_OPTION_STRUCT_LENGTH ))
        column_spec[2]="${options[i+_DOCOPT_OPTION_POSITION_SHORT]}"
        column_spec[4]="${options[i+_DOCOPT_OPTION_POSITION_LONG]}"
        column_spec[6]="${options[i+_DOCOPT_OPTION_POSITION_ARGUMENT]}"
        column_spec[8]="${options[i+_DOCOPT_OPTION_POSITION_DEFAULT]}"
        e="${options[i+_DOCOPT_OPTION_POSITION_OCCURANCE]}"
        case "$e" in
            6) e=once;;
            7) e=cont;;
            *) printf 'Unknown occurance: %s\n' "$e" >&2; return 1;;
        esac
        # shellcheck disable=SC2034
        column_spec[10]="$e"
        print-table-row
    done

    print-table-hr
}

function parse-options {
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking print-options-table\n' >&2
        return 1
    fi

    local -n err

    # $option   the current option e.g. [-o, --option] name that is beign built.
    # $argument the current argument

    local USAGE line char \
          short long argument default arg def option \
          is_option=false is_short=false \
          is_single_space=false is_argument=false \
          is_description=false is_default=false \
          i=-1

    local -i exit_code=0

    USAGE=$1
    err=$2

    while IFS= read -r line; do
        if test -z "$line"; then continue; fi
        if grep -qE '^\s+-' <<< "$line"; then
            # debug-line "$line"

            # shellcheck disable=SC1007
            short= long= argument= default= option= arg= def=
            is_option=false is_short=false
            is_single_space=false is_argument=false
            is_description=false is_default=false
            i=-1

            while IFS= read -r -n1 char; do
                if ! test $exit_code -eq 0; then break 2; fi

                i=$((i + 1))
                if test -z "$char"; then continue; fi

                # debug-line-printf "$line" 'is_argument     = %s\n' "$is_argument"
                # debug-line-printf "$line" 'is_default      = %s\n' "$is_default"
                # debug-line-printf "$line" 'is_description  = %s\n' "$is_description"
                # debug-line-printf "$line" 'is_option       = %s\n' "$is_option"
                # debug-line-printf "$line" 'is_short        = %s\n' "$is_short"
                # debug-line-printf "$line" 'is_single_space = %s\n' "$is_single_space"
                # debug-line-printf "$line" 'option          = %s\n' "$option"
                # debug-line-printf "$line" 'def             = %s\n' "$def"
                # debug-line-printf "$line" 'arg             = %s\n' "$arg"
                # debug-line-printf "$line" 'short           = %s\n' "$short"
                # debug-line-printf "$line" 'long            = %s\n' "$long"
                # debug-line-printf "$line" 'argument        = %s\n' "$argument"
                # debug-line-printf "$line" 'default         = %s\n' "$default"
                # debug-line-printf "$line" '\n'
                # debug-line-single "$line" "$i"

                if [[ "$char" == "," ]]; then
                    # [-o,]
                    # [-o ARG,]
                    # [-o=ARG,]
                    # [--option,]
                    # [--option ARG,]
                    # [--option=ARG,]
                    continue;
                fi

                if [[ "$char" == "[" ]]; then
                    if $is_description; then
                        is_default=true
                    fi
                    continue
                fi

                if [[ "$char" == "]" ]]; then
                    if $is_default && ! test -z "$def"; then
                        default="$def"
                        def=
                    fi
                    is_default=false
                    continue
                fi

                if [[ "$char" == " " ]]; then
                    # [-o ]
                    # [-o  ]
                    # [-o ARG ]
                    # [-o ARG  ]
                    # [--option ]
                    # [--option  ]
                    # [--option ARG ]
                    # [--option ARG  ]
                    # [--option=ARG ]
                    # [--option=ARG  ]
                    # [  [default: ]

                    if $is_default; then
                        # [  [default: ]
                        if ! test -z "$def"; then
                            def+="$char"
                        fi
                        continue
                    fi

                    if $is_single_space || $is_description; then
                        # [-o  ]
                        # [-o ARG  ]
                        # [-o=ARG  ]
                        # [--option  ]
                        # [--option ARG  ]
                        # [--option=ARG  ]
                        is_description=true
                        is_single_space=false
                        continue
                    fi

                    if ! $is_single_space && ($is_option || $is_argument); then
                        # [-o ]
                        # [-o ARG ]
                        # [--option ]
                        # [--option ARG ]
                        is_single_space=true
                    fi

                    is_argument=false

                    if ! test -z "$arg"; then
                        # [-o ARG ]
                        # [-o=ARG ]
                        # [--option ARG ]
                        # [--option=ARG ]

                        if ! test -z "$argument" && [[ "$argument" != "$arg" ]]; then
                            # shellcheck disable=SC2034
                            printf -v err 'Argument: %s should match %s in option %s %s' "$arg" "$argument" "$long" "$short"
                            exit_code=1
                            continue
                        fi

                        argument="$arg"
                        arg=
                    fi

                    if ! test -z "$option"; then
                        # [-o ]
                        # [--option ]
                        if $is_short; then
                            # [-o ]
                            short="$option"
                        else
                            # [--option ]
                            long="$option"
                        fi
                        # shellcheck disable=SC1007
                        option= # reset option variable
                    fi

                    is_argument=$is_option
                    is_option=false
                    is_short=false
                    continue
                fi

                if [[ "$char" == "-" ]]; then
                    # [-]
                    # [--]...
                    if $is_default; then
                        def+="$char"
                        continue
                    fi

                    if $is_argument && ! test -z "$arg"; then
                        # [-o=ARGU-MENT]
                        # [-o ARGU-MENT]
                        # [--option=ARGU-MENT]
                        # [--option ARGU-MENT]
                        arg+="$char"
                        continue
                        # arg= #reset arg variable
                    fi

                    if $is_option && $is_single_space && ! test -z "$option"; then
                        # [--option -]
                        # [-o -]
                        if ! test -z "$option"; then
                            if $is_short; then
                                short="$option"
                            else
                                long="$option"
                            fi
                            # shellcheck disable=SC1007
                            option= # reset option variable
                        fi
                    fi


                    if $is_option && ! $is_short && ! $is_single_space; then
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

                is_single_space=false

                if [[ "$char" == "=" ]]; then
                    if $is_option && ! test -z "$option"; then
                        # [-o=]
                        # [--option=]
                        if $is_short; then
                            short="$option"
                        else
                            long="$option"
                        fi
                        # shellcheck disable=SC1007
                        option= # reset option variable
                    fi

                    if ! $is_description && test -z "$arg"; then
                        # if no agument has been found for current option
                        is_argument=true
                    fi

                    is_option=false
                    is_short=false
                    continue
                fi

                if $is_default; then
                    def+="$char"
                    if [[ "default:" == "$def" ]]; then
                        def=
                    fi
                fi

                if ! $is_option && ! $is_description && $is_argument; then
                    # [-o ARG]
                    # [-o=ARG]
                    # [--option ARG]
                    # [--option=ARG]
                    is_argument=true
                    arg+="$char"
                fi

                if $is_option; then
                    # [-o]
                    # [--option]
                    option+="$char"
                fi

            done <<< "$line"

            options+=( "$short" "$long" "$argument" "$default" "$_DOCOPT_PROGRAM_OCCURANCE_ONCE" )
        fi
    done <<< "$USAGE"

    return $exit_code
}
