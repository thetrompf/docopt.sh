#!/bin/bash -e

# shellcheck disable=SC1091
source ./util.sh

function print-options-table {
    local -n shorts longs arguments defaults
    shorts=$1 longs=$2 arguments=$3 defaults=$4

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

    local e i
    for e in "${!longs[@]}"; do if [[ "${#e}" -gt "$width_idx" ]]; then width_idx="${#e}"; fi; done
    for e in "${shorts[@]}"; do if [[ "${#e}" -gt "$width_short" ]]; then width_short="${#e}"; fi; done
    for e in "${longs[@]}"; do if [[ "${#e}" -gt "$width_long" ]]; then width_long="${#e}"; fi; done
    for e in "${arguments[@]}"; do if [[ "${#e}" -gt "$width_argument" ]]; then width_argument="${#e}"; fi; done
    for e in "${defaults[@]}"; do if [[ "${#e}" -gt "$width_default" ]]; then width_default="${#e}"; fi; done

    local -a column_spec=( \
        "$header_idx" "$width_idx" \
        "$header_short" "$width_short" \
        "$header_long" "$width_long" \
        "$header_argument" "$width_argument" \
        "$header_default" "$width_default"
    )

    print_table_header column_spec

    for i in "${!longs[@]}"; do
        column_spec[0]="$i"
        column_spec[2]="${shorts[i]}"
        column_spec[4]="${longs[i]}"
        column_spec[6]="${arguments[i]}"
        # shellcheck disable=SC2034
        column_spec[8]="${defaults[i]}"
        print_table_row column_spec
    done

    print_table_line column_spec
}

function parse-options {
    local -n shorts longs arguments defaults

    # $option   the current option e.g. [-o, --option] name that is beign built.
    # $argument the current argument

    local USAGE line char \
          short long argument default arg def option \
          is_option=false is_short=false \
          is_single_space=false is_argument=false \
          is_description=false is_default=false \
          i=-1

    USAGE=$1
    shorts=$2
    longs=$3
    arguments=$4
    defaults=$5

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
                            printf 'Argument: %s should match %s in option %s\n' "$arg" "$argument" "$long" >&2
                            return 1
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

            shorts+=( "$short" )
            longs+=( "$long" )
            arguments+=( "$argument" )
            defaults+=( "$default" )
        fi
    done <<< "$USAGE"
}
