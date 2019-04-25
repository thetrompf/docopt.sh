#!/bin/bash

printf -- '###############################\n'
printf -- '# Running docopt parser tests #\n'
printf -- '###############################\n\n'
bash test-docopt.sh
printf -- '\n\n'

printf -- '###############################\n'
printf -- '# Running args builder tests  #\n'
printf -- '###############################\n\n'
bash test-args.sh
printf '\n\n'

printf -- '###############################\n'
printf -- '# Running argv parser tests   #\n'
printf -- '###############################\n\n'
bash test-argv.sh
