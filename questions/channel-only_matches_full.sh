#!/bin/bash
###################################
##q Candidate channel-only test against candidate full model
##q Question: Does the candidate channel-only match the full model?
##q Directories: 
##q    full-model run  : $domainRunDir/run.candidate
##q    channel-only run: $domainRunDir/run.candidate.channel-only
##q Compares: All (time) restart HYDRO_RST on comparable fields, nudging
##q           restart files (if available), and CHRTOUT files on comparable
##q           fields.
###################################
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mCandidate binary: running in channel-only mode with $nCoresFull \e[0m"

cd $domainTestDir/run.candidate.channel-only || \
    { echo "Can not cd to ${domainRunDir}/run.candidate.channel-only Exiting."; exit 1; }

cp $testBinary .
echo mpirun -np $nCoresDefault ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
mpirun -np $nCoresFull ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 

cd ../
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mTest: # cores test\e[0m"

#compare restart files
python3 $answerKeyDir/compare_restarts.py \
        $domainTestDir/run.candidate \
        $domainTestDir/run.candidate.channel-only \
    || { echo -e "\e[5;49;31m# cores test: restarts comparison failed.\e[0m"; exit 1; }
echo -e "\e[5;49;32m# cores test: restart comparison successful!\e[0m"    

exit 0
