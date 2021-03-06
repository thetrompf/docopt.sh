#!/bin/bash -e
# shellcheck disable=SC2034

readonly \
    _DOCOPT_OPTION_STRUCT_LENGTH=5 \
    _DOCOPT_OPTION_POSITION_SHORT=0 \
    _DOCOPT_OPTION_POSITION_LONG=1 \
    _DOCOPT_OPTION_POSITION_ARGUMENT=2 \
    _DOCOPT_OPTION_POSITION_DEFAULT=3 \
    _DOCOPT_OPTION_POSITION_OCCURANCE=4 \
    \
    _DOCOPT_ARGUMENT_STRUCT_LENGTH=3 \
    _DOCOPT_ARGUMENT_POSITION_NAME=0 \
    _DOCOPT_ARGUMENT_POSITION_TYPE=1 \
    _DOCOPT_ARGUMENT_POSITION_OCCURANCE=2 \
    \
    _DOCOPT_PROGRAM_NECESSITY_REQUIRED=1 \
    _DOCOPT_PROGRAM_NECESSITY_OPTIONAL=2 \
    _DOCOPT_PROGRAM_ARG_TYPE_OPTION=3 \
    _DOCOPT_PROGRAM_ARG_TYPE_POSITIONAL=4 \
    _DOCOPT_PROGRAM_ARG_TYPE_COMMAND=5 \
    _DOCOPT_PROGRAM_OCCURANCE_ONCE=6 \
    _DOCOPT_PROGRAM_OCCURANCE_CONTINOUS=7 \
    _DOCOPT_END_OF_PROGRAM=EOP
