#!/bin/bash
###################################
##q Candidate Regression Test onto v1.2_release-gwFix-qstrmvolrtFix
##q This is such a messed up case that it warrants doing in it's own 
##q test file because we dont yet have the capabilities to deal with the
##q namelist issues. 
##q Question: Does the Candidate run match a reference run?
##q Directories:
##q    reference compile: Either $REPO_DIR/reference (if code is remote), or
##q                       $referenceLocalPath if code is local.
##q    reference run    : $domainRunDir/run.reference.v1-2-release-gwFix-qstrmvolrtFix
##q Compares: All restart files RESTART, HYDRO_RST, and nudging (if available). 
###################################

questionFileName=regression.v1-2-release-gwFix-qstrmvolrtFix.sh
## questionFileName is used by the following script
source $toolboxDir/setup_compile_reference_repo.sh


###################################
## Run Reference Binary
###################################
## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32mRunning reference binary (with $nCoresDefault cores).\e[0m"
cd $domainRunDir/run.reference.v1-2-release-gwFix-qstrmvolrtFix || \
    { echo "Can not cd to ${domainRunDir}/run.reference.v1-2-release-gwFix-qstrmvolrtFix Exiting."; exit 1; }
cp $referenceBinary .

if [[ -z $WRF_HYDRO_RUN ]]; then source $toolboxDir/mpiRun.sh; fi
$WRF_HYDRO_RUN $nCoresDefault $referenceBinary question_reg-v1.2-release-plus $TEST_WALL_TIME

## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
nSuccessDiag=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
nSuccessStdout=`grep 'The model finished successfully.......' *.stdout | wc -l`
nSuccess=$(($nSuccessDiag + $nSuccessStdout))
if [[ $nSuccess -ne $nCoresDefault ]]; then
    echo -e "\e[5;49;31mReference binary: run failed unexpectedly.\e[0m"
    echo "See results in $domainRunDir/run.reference.v1-2-release-gwFix-qstrmvolrtFix"
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
        $domainRunDir/run.reference.v1-2-release-gwFix-qstrmvolrtFix || \
    { echo -e "\e[5;49;31mAnswer: Regression test restart comparison failed.\e[0m"; 
      echo "Files compared are in the directories:"
      echo "$domainRunDir/run.candidate"
      echo "$domainRunDir/run.reference.v1-2-release-gwFix-qstrmvolrtFix"
      exit 1; }
echo -e "\e[5;49;32mAnswer: Regression test restart comparison successful!\e[0m"

exit 0
