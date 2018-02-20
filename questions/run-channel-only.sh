#!/bin/bash
###################################
##q Run Candidate Binary in Channel-Only Mode
##q Question: Does the candidate binary run to completion in channel-only mode?
##q Directory: $domainRunDir/run.candidate-channel-only
##q Compares: The number of diag_hydro files with the
##q           "The model finished successfully..."
##q           to the number of cores used in the run.
###################################
theRunDir=$domainRunDir/run.candidate-channel-only
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mrun-channel-only.sh:\e[0m"
echo -e "\e[0;49;32mQuestion: Does the candidate binary channel-only mode run? (using $nCoresDefault cores).\e[0m"
cd $theRunDir || \
    { echo "Can not cd to $theRunDir. Exiting."; exit 1; }
echo "Running in $theRunDir"
cp $candidateBinary . || {
    echo -e "Candidate binary not found";
    exit 1;}

if [[ -z $WRF_HYDRO_RUN ]]; then source $toolboxDir/mpiRun.sh; fi
$WRF_HYDRO_RUN $nCoresDefault $candidateBinary question_run $TEST_WALL_TIME

## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
## Intel and GNU write this message to different files. This requires that standard out
## under intel is writen to a file ending in "stdout"
nSuccessDiag=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
nSuccessStdout=`grep 'The model finished successfully.......' *.stdout | wc -l`
nSuccess=$(($nSuccessDiag + $nSuccessStdout))
if [[ $nSuccess -ne $nCoresDefault ]]; then
    echo -e "\e[5;49;31mAnswer: Candidate binary channel-only run failed.\e[0m"
    echo "See results in $theRunDir"
    exit 1
fi
echo -e "\e[5;49;32mAnswer: Candidate binary channel-only run successful!\e[0m"
exit 0
