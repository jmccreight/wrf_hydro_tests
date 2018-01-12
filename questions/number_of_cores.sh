#!/bin/bash
###################################
##q Candidate # Cores Test
##q Question: Does the result depend on the number of cores used for MPI?
##q Directories:
##q    Run with nCoresDefault: $domainRunDir/run.candidate
##q    Run with nCoresTest:    $domainRunDir/run.candidate.ncores_test
##q Compares: All restart files RESTART, HYDRO_RST, and nudging (if available). 
###################################
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mnumber_of_cores.sh:\e[0m"
echo -e "\e[0;49;32mRunning candidate binary with $nCoresTest cores.\e[0m"

cd $domainRunDir/run.candidate.ncores_test || \
    { echo "Can not cd to $domainRunDir/run.candidate.ncores_test. Exiting."; exit 1; }
cp $candidateBinary .
mpirun -np $nCoresTest ./`basename $candidateBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
nSuccessDiag=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
nSuccessStdout=`grep 'The model finished successfully.......' *.stdout | wc -l`
nSuccess=$(($nSuccessDiag + $nSuccessStdout))
if [[ $nSuccess -ne $nCoresTest ]]; then
    echo -e "\e[5;49;31mCandidate binary run failed unexpectedly with $nCoresTest cores.\e[0m"
    exit 1
fi
echo -e "\e[0;49;32mCandidate binary run successful with $nCoresTest cores.\e[0m"

cd ../
echo
echo -e "\e[0;49;32mQuestion: Are restarts unchanged with the number of cores used?\e[0m"

#compare restart files
python3 $answerKeyDir/compare_restarts.py \
        $domainRunDir/run.candidate \
        $domainRunDir/run.candidate.ncores_test \
    || { echo -e "\e[5;49;31mAnswer: Number of  cores test restart comparison failed.\e[0m"; 
         echo "Files compared are in the directories:"
         echo "$domainRunDir/run.candidate"
         echo "$domainRunDir/run.candidate.ncores_test"
         exit 1; }
echo -e "\e[5;49;32mAnswer: Number of cores test restart comparison successful!\e[0m"    

exit 0
