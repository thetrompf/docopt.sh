#!/bin/bash -e


function print-options-table {
    # structure (short, long, argument, default)
    if ! declare -p options 2> /dev/null | grep -q 'declare \-a'; then
        printf 'The "options" variable must be declared as an array before invoking print-options-table\n' >&2
        return 1
    fi

    # shellcheck disable=SC1091
    source ./util.sh

    local header_idx='IDX' \
          header_short='SHORT' \
          header_long='LONG' \
          header_argument='ARG' \
          header_default='DEFAULT'

    local width_idx=${#header_idx} \
          width_short=${#header_short} \
          width_long=${#header_long} \
          width_argument=${#header_argument} \
          width_default=${#header_default}

    local e i=0
    for (( i=0; i<${#options[@]}; i+=4 )); do
        e=$(( i / 4 )); if (( ${#e} > width_idx )); then width_idx=${#e}; fi
        e="${options[i]}"; if (( ${#e} > width_short )); then width_short=${#e}; fi
    done
    for (( i=1; i<${#options[@]}; i+=4 )); do
        e="${options[i]}"; if (( ${#e} > width_long )); then width_long=${#e}; fi;
    done
    for (( i=2; i<${#options[@]}; i+=4 )); do
        e="${options[i]}"; if (( ${#e} > width_argument )); then width_argument=${#e}; fi;
    done
    for (( i=3; i<${#options[@]}; i+=4 )); do
        e="${options[i]}"; if (( ${#e} > width_default )); then width_default=${#e}; fi;
    done

    local -a column_spec=( \
        "$header_idx"      "$width_idx" \
        "$header_short"    "$width_short" \
        "$header_long"     "$width_long" \
        "$header_argument" "$width_argument" \
        "$header_default"  "$width_default"
    )

    print_table_header column_spec

    for (( i=0; i<${#options[@]}; i+=4 )); do
        e=$(( i / 4 ))
        column_spec[0]=$(( i / 4))
        column_spec[2]="${options[i]}"
        column_spec[4]="${options[i+1]}"
        column_spec[6]="${options[i+2]}"
        # shellcheck disable=SC2034
        column_spec[8]="${options[i+3]}"
        print_table_row column_spec
    done

    print_table_hr column_spec
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

    # shellcheck disable=SC1091
    source ./util.sh

    USAGE=$1
    err=$2

    while IFS= read -r line; do
        if test -z "$line"; then continue; fi
        if grep -qE '^\s+-' <<< "$line"; then
            # debug_line "$line"

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

                # debug_line_printf "$line" 'is_argument     = %s\n' "$is_argument"
                # debug_line_printf "$line" 'is_default      = %s\n' "$is_default"
                # debug_line_printf "$line" 'is_description  = %s\n' "$is_description"
                # debug_line_printf "$line" 'is_option       = %s\n' "$is_option"
                # debug_line_printf "$line" 'is_short        = %s\n' "$is_short"
                # debug_line_printf "$line" 'is_single_space = %s\n' "$is_single_space"
                # debug_line_printf "$line" 'option          = %s\n' "$option"
                # debug_line_printf "$line" 'def             = %s\n' "$def"
                # debug_line_printf "$line" 'arg             = %s\n' "$arg"
                # debug_line_printf "$line" 'short           = %s\n' "$short"
                # debug_line_printf "$line" 'long            = %s\n' "$long"
                # debug_line_printf "$line" 'argument        = %s\n' "$argument"
                # debug_line_printf "$line" 'default         = %s\n' "$default"
                # debug_line_printf "$line" '\n'
                # debug_line_single "$line" "$i"

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
                    # [-o=ARG ]
                    # [-o=ARG  ]
                    # [--option ]
                    # [--option  ]
                    # [--option ARG ]
                    # [--option ARG  ]
                    # [--option=ARG ]
                    # [--option=ARG  ]
                    # [  [default: ]

                    if $is_default; then
                        # [  [default: ]
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

            options+=( "$short" "$long" "$argument" "$default" )
        fi
    done <<< "$USAGE"

    return $exit_code
}
