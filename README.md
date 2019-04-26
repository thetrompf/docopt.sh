# docopt.sh

:warning::construction: Under development :construction::warning:

## TODO LIST

### docopt text parser

#### OPTIONS

```
Usage:
    program defintion

Options:
    <this area>
```

-   [ ] short option
    -   [x] ✓ `-o`
    -   [x] ✓ `-o ARG`
    -   [x] ✓ `-o <arg>`
    -   [ ] ✓ `-o ARG...`
    -   [ ] ✓ `-o <arg>...`
-   [ ] long option
    -   [x] ✓ `--option`
    -   [x] ✓ `--option ARG`
    -   [x] ✓ `--option=ARG`
    -   [x] ✓ `--option <arg>`
    -   [x] ✓ `--option=<arg>`
    -   [ ] ✓ `--option ARG...`
    -   [ ] ✓ `--option <arg>...`
    -   [ ] ✓ `--option=ARG...`
    -   [ ] ✓ `--option=<arg>...`
-   [x] option with default value
    -   [x] ✓ `[default: value]`
    -   [x] ✓ `Option description. [default: value]`
-   [ ] comma between short and long options
    -   [x] ✓ `-o, --option`
    -   [x] ✓ `-o ARG, --option`
    -   [x] ✓ `-o <arg>, --option`
    -   [ ] ✓ `-o ARG..., --option`
    -   [ ] ✓ `-o <arg>..., --option`
-   [ ] not necessary to define `ARG` / `<arg>` for both short and long option
    -   [x] ✓ `-o ARG --option`
    -   [x] ✓ `-o --option ARG`
    -   [ ] ✓ `-o ARG... --option`
    -   [ ] ✓ `-o --option ARG...`

#### PROGRAMS

```
Usage:
    <this area>

Options:
    options definition
```

-   [ ] short option
    -   [x] ✓ `-o`
    -   [x] ✓ `-o ARG`
    -   [x] ✓ `-o <arg>`
    -   [x] ✗ `-o WRONG_ARG` throw error if there is mismatch in naming of arguments declared in options area.
    -   [x] ✓ `-o` without `ARG` but it is declared in options that it takes an argument.
    -   [x] ✓ `-v...` continous option.
    -   [ ] ✓ `-o ARG...`
    -   [ ] ✓ `-o <arg>...`
    -   [ ] ✗ `-v...` throw error if it declared in options that it takes an argument.
    -   [ ] ✓ `-abc` consecutive short options with a single dash .
-   [ ] long option
    -   [x] ✓ `--option`
    -   [x] ✓ `--option ARG`
    -   [x] ✓ `--option=ARG`
    -   [x] ✓ `--option <arg>`
    -   [x] ✓ `--option=<arg>`
    -   [x] ✓ `--option` without `ARG` it is declared in options that it takes an argument.
    -   [x] ✗ `--option WRONG_ARG` throw error if there is mismatch in naming of arguments declared in options area.
    -   [x] ✓ `--verbose...` continous option
    -   [ ] ✓ `--option ARG...`
    -   [ ] ✓ `--option=ARG...`
    -   [ ] ✓ `--option <arg>...`
    -   [ ] ✓ `--option=<arg>...`
    -   [ ] ✗ `--verbose...` throw error if it declared in options that it takes an argument.
-   [ ] optional options
    -   [x] ✓ `[-o]`
    -   [x] ✓ `[-o ARG]`
    -   [x] ✓ `[-o ARG...]`
    -   [x] ✓ `[-o <arg>]`
    -   [x] ✓ `[--option]`
    -   [x] ✓ `[--option ARG]`
    -   [x] ✓ `[--option=ARG]`
    -   [x] ✓ `[--option <arg>]`
    -   [x] ✓ `[--option=<arg>]`
    -   [ ] ✓ `[-o <arg>...]`
    -   [ ] ✓ `[--option ARG...]`
    -   [ ] ✓ `[--option=ARG...]`
    -   [ ] ✓ `[--option <arg>...]`
    -   [ ] ✓ `[--option=<arg>...]`
    -   [ ] ✓ `[options]` special "all options" allowed in no particular order.
-   [x] commands
    -   [x] ✓ `command`
    -   [x] ✓ `command...`
    -   [x] ✓ `[command]` optional command.
    -   [x] ✓ `[command...]` optional continous command.
-   [x] positional argument
    -   [x] ✓ `ARG`
    -   [x] ✓ `ARG...` continous argument resolves to multiple values.
    -   [x] ✓ `ARG ARG...` singular and plural definition resolves to multiple values.
-   [ ] multiple optionals
    -   [ ] ✓ `[--input --output]` multiple long options inside a single pair of brackets.
    -   [ ] ✓ `[-i -o]` multiple short options inside a single pair of brackets.
    -   [ ] ✓ `[-io]` consecutiave short options.
    -   [ ] ✓ `[FILE1 FILE2]` positional arguments.
-   [ ] grouping
    -   [x] ✓ `--option1 | --option2 | --option3 ...`
    -   [x] ✓ `command1 | command2 | command3 ...`
    -   [ ] ✓ `(--input --ouput | --in --out)` multiple required pairs

#### ARGS BUILDING

```sh
declare -A ARGS=(
    ...this area
)
_docopt ()(...)
```

-   [x] short option
    -   [x] ✓ `-o` short option without long counterpart resolves to short name with `-` prefix.
    -   [x] ✓ Defaults to false when no argument is declared.
    -   [x] ✓ Defatuls to empty `-o=` when argument is declared without a default.
    -   [x] ✓ `[-i FILE] [default: -]` Defaults declared default value.
-   [x] long option
    -   [x] ✓ `--option` long option resolves to name with `--` prefix.
    -   [x] ✓ Defaults to false.
    -   [x] ✓ Defatuls to empty `--option=` when argument is declared without a default.
    -   [x] ✓ `[--input FILE] [default: -]` Defaults to declared default value.
-   [x] short and long
    -   [x] ✓ `-o --option` resolves to long name with `--` prefix.
-   [x] command
    -   [x] ✓ `command` Defaults to `false` on singular value.
    -   [x] ✓ `command...` Defaults to `0` on continous values.
-   [x] positional
    -   [x] ✓ `ARG` Defaults to empty `ARG=` on singular value.
    -   [x] ✓ `ARG...` Defaults to empty `ARG=` on continous values.

#### ARGV PARSER

```shell
$ program <this area>
```

-   [x] ✓ empty program
-   [ ] option
    -   [x] ✓ `--option` match required without argument.
    -   [ ] ✓ `--option=ARG` match required with argument.
    -   [ ] ✓ `--` match provided optional wihout argument.
    -   [ ] ✓ match provided optional with argument.
    -   [ ] ✓ match non-provided optional wihout argument.
    -   [ ] ✓ match non-provided optional with argument.
    -   [x] ✗ error on non-exiting option.
-   [ ] command
    -   [x] ✓ match required singular.
    -   [ ] ✓ match required continous.
    -   [ ] ✓ match provided optional singular.
    -   [ ] ✓ match provided optional continous.
    -   [ ] ✓ match non-provided optional singular.
    -   [ ] ✓ match non-provided optional continous.
    -   [x] ✗ error on non-exiting command.
-   [ ] positional
    -   [ ] ✓ `ARG` match required singular.
    -   [ ] ✓ `ARG...` match required continous.
    -   [ ] ✓ `[ARG]` match provided optional singular.
    -   [ ] ✓ `[ARG...]` match provided optional continous.
    -   [ ] ✓ `[ARG]` match non-provided optional singular.
    -   [ ] ✓ `[ARG...]` match non-provided optional continous.
    -   [x] ✗ error when required not met.
