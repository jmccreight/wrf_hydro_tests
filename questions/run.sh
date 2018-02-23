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
echo "Running in $domainRunDir/run.candidate"
cp $candidateBinary . || {
    echo -e "Candidate binary not found";
    exit 1;}
cp $candidateRepoDir/trunk/NDHMS/Run/*TBL . || {
    echo -e "Candidate parameter tables not found";
    exit 1;}

if [[ -z $WRF_HYDRO_RUN ]]; then source $toolboxDir/mpiRun.sh; fi
$WRF_HYDRO_RUN $nCoresDefault $candidateBinary question_run $TEST_WALL_TIME $TEST_QUEUE

## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
## Intel and GNU write this message to different files. This requires that standard out
## under intel is writen to a file ending in "stdout"
nSuccessDiag=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
nSuccessStdout=`grep 'The model finished successfully.......' *.stdout | wc -l`
nSuccess=$(($nSuccessDiag + $nSuccessStdout))
if [[ $nSuccess -ne $nCoresDefault ]]; then
    echo -e "\e[5;49;31mAnswer: Candidate binary run failed.\e[0m"
    echo "See results in $domainRunDir/run.candidate"
    exit 1
fi
echo -e "\e[5;49;32mAnswer: Candidate binary run successful!\e[0m"
exit 0
