#!/bin/bash
###################################
##q Candidate Regression Test
##q Question: Does the Candidate run match a reference run?
##q Directories:
##q    reference compile: Either $REPO_DIR/reference (if code is remote), or
##q                       $referenceLocalPath if code is local.
##q    reference run    : $domainRunDir/run.reference
##q Compares: All restart files RESTART, HYDRO_RST, and nudging (if available). 
###################################

## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mregression.sh:\e[0m"
echo -e "\e[0;49;32mCompiling reference binary.\e[0m"
if [[ -z $referenceLocalPath ]]; then
    cd $refRepoDir/trunk/NDHMS/
else
    cd $referenceLocalPath/trunk/NDHMS/
fi
echo
$WRF_HYDRO_TESTS_DIR/toolbox/config_compile_NoahMP.sh || \
    { echo -e "\e[5;49;31mReference binary: compilation under GNU failed unexpectedly.\e[0m"; exit 1; }
echo -e "\e[0;49;32mReference binary: compilation under GNU successful.\e[0m"

###################################
## Run Reference Binary
###################################
## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32mRunning reference binary (with $nCoresDefault cores).\e[0m"
cd $domainRunDir/run.reference || \
    { echo "Can not cd to ${domainRunDir}/run.reference Exiting."; exit 1; }
cp $referenceBinary .
mpirun -np $nCoresDefault ./`basename $referenceBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
nSuccessDiag=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
nSuccessStdout=`grep 'The model finished successfully.......' *.stdout | wc -l`
nSuccess=$(($nSuccessDiag + $nSuccessStdout))
if [[ $nSuccess -ne $nCoresDefault ]]; then
    echo -e "\e[5;49;31mReference binary: run failed unexpectedly.\e[0m"
    echo "See results in $domainRunDir/run.reference"
    exit 1
fi
echo -e "\e[0;49;32mReference binary: run successful.\e[0m"

###################################
## Regression of candidate on reference
###################################
echo
echo -e "\e[0;49;32mQuestion: Do candidate results regress on to reference results?\e[0m"

#compare restart files
python3 $answerKeyDir/compare_restarts.py \
        $domainRunDir/run.candidate \
        $domainRunDir/run.reference || \
    { echo -e "\e[5;49;31mAnswer: Regression test restart comparison failed.\e[0m"; 
      echo "Files compared are in the directories:"
      echo "$domainRunDir/run.candidate"
      echo "$domainRunDir/run.reference"
      exit 1; }
echo -e "\e[5;49;32mAnswer: Regression test restart comparison successful!\e[0m"

exit 0
