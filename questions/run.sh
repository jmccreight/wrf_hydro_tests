#!/bin/bash
###################################
##q Run Candidate Binary
##q Question: Does the candidate binary run to completion?
##q Directory: $domainRunDir/run.candidate
##q Compares: The number of diag_hydro files with the
##q           "The model finished successfully..."
##q           to the number of cores used in the run.
###################################
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mrun.sh:\e[0m"
echo -e "\e[0;49;32mQuestion: Does the candidate binary run? (using $nCoresDefault cores).\e[0m"
cd $domainRunDir/run.candidate || \
    { echo "Can not cd to ${domainRunDir}/run.candidate. Exiting."; exit 1; }
cp $candidateBinary .
mpirun -np $nCoresDefault ./`basename $candidateBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
nSuccess=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
if [[ $nSuccess -ne $nCoresDefault ]]; then
    echo -e "\e[5;49;31mAnswer: Candidate binary run failed.\e[0m"
    exit 1
fi
echo -e "\e[5;49;32mAnswer: Candidate binary run successful!\e[0m"
exit 0
