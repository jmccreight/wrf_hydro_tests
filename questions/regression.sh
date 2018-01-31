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

###################################
## Clone reference fork into repos directory
###################################
## The reference fork can be optional if both $referenceLocalPath and $referenceFork equal ''.
if [[ -z $referenceLocalPath ]]; then
    if [[ ! -z $referenceFork ]]; then
	if [[ -e $refRepoDir ]]; then
            chmod -R 755 $refRepoDir
            rm -rf $refRepoDir
	fi
	mkdir -p $refRepoDir
	cd $refRepoDir
	echo -e "\e[0;49;32m-----------------------------------\e[0m"
	echo -e "\e[7;49;32mReference fork: $referenceFork\e[0m"
	echo -e "\e[7;49;32mReference branch/commit: $referenceBranchCommit\e[0m"
	git clone https://${authInfo}@github.com/$referenceFork $refRepoDir    
	git checkout $referenceBranchCommit || \
            { echo "Unsuccessful checkout of $referenceBranchCommit from $referenceFork."; exit 1; }
	echo -e "\e[0;49;32mRepo in\e[0m `pwd`"
	echo -e "\e[0;49;32mReference branch:\e[0m    `git rev-parse --abbrev-ref HEAD`"
	echo -e "\e[0;49;32mReference commit:\e[0m"
	git log -n1 | cat
    fi
else
    cd $referenceLocalPath
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mReference fork: LOCAL: `pwd` \e[0m"
    echo -e "\e[0;49;32mReference branch:\e[0m    `git rev-parse --abbrev-ref HEAD`"
    gitDiffInd=`git diff-index HEAD -- `
    if [[ -z $gitDiffInd ]]; then 
        echo -e "\e[0;49;32mTesting commit:\e[0m"
        git log -n1 | cat
    else 
        echo  -e "\e[0;49;32mTesting uncommitted changes.\e[0m"
    fi
    cd - >/dev/null 2>&1
fi



## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mregression.sh:\e[0m"
echo -e "\e[0;49;32mCompiling reference binary.\e[0m"
if [[ -z $referenceLocalPath ]]; then
    cd $refRepoDir/trunk/NDHMS/
    theCompDir=$referenceRepoDir/trunk/NDHMS/
else
    cd $referenceLocalPath/trunk/NDHMS/
    theCompDir=$referenceLocalPath/trunk/NDHMS/
fi
echo "Compiling in $theCompDir"
echo
$toolboxDir/config_compile_NoahMP.sh || \
    { echo -e "\e[5;49;31mReference binary: compilation under $WRF_HYDRO_COMPILER failed unexpectedly.\e[0m"; 
      echo "See results in $theCompDir"; 
      exit 1; }
echo -e "\e[0;49;32mReference binary: compilation under $WRF_HYDRO_COMPILER successful.\e[0m"

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

$WRF_HYDRO_RUN $nCoresDefault $referenceBinary question_regression $TEST_WALL_TIME

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
