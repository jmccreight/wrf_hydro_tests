#!/bin/bash

cat README.header.md > README.md

questionFiles="compile.sh run.sh perfect_restart.sh number_of_cores.sh regression.sh channel-only_matches_full.sh"

for ff in ${questionFiles}; do
    echo >> README.md
    echo "## $ff" >> README.md
    egrep '^##q' $ff | cut -c5- >> README.md 
done


exit 0


