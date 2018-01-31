#!/bin/bash
###################################
##q Compile Candidate Binary
##q Question: Does the candidate binary compile?
##q Directory: Either $REPO_DIR/candidate (if code is remote), or
##q            $candidateLocalPath if code is local.
###################################

###################################
## Clone candidate fork
###################################
## If running in circleCI, this clone is not necessary. So this section is conditional
## on the CIRCLECI environment variables.
## If running locally, clone specified candidate fork, otherwise in circleCI the current
## PR/Commit is used as candidate.
if [[ -z ${CIRCLECI} ]]; then 
    if [[ -z $candidateLocalPath ]]; then
        if [[ -e $candidateRepoDir ]]; then
            chmod -R 755 $candidateRepoDir
            rm -rf $candidateRepoDir
        fi
        mkdir -p $candidateRepoDir
        cd $candidateRepoDir    
        echo
        echo -e "\e[0;49;32m-----------------------------------\e[0m"
        echo -e "\e[7;49;32mCandidate fork: $candidateFork\e[0m"
	echo -e "\e[7;49;32mCandidate branch/commit: $candidateBranchCommit\e[0m"
        git clone https://${authInfo}@github.com/$candidateFork $candidateRepoDir
        git checkout $candidateBranchCommit || \
            { echo "Unsuccessful checkout of $candidateBranchCommit from $candidateFork."; exit 1; }
        echo -e "\e[0;49;32mRepo moved to\e[0m `pwd`"
        echo -e "\e[0;49;32mCandidate branch:\e[0m    `git rev-parse --abbrev-ref HEAD`"
        echo -e "\e[0;49;32mTesting commit:\e[0m"
        git log -n1 | cat
    else
        cd $candidateLocalPath
        echo
        echo -e "\e[0;49;32m-----------------------------------\e[0m"
        echo -e "\e[7;49;32mCandidate fork: LOCAL: `pwd` \e[0m"
        echo -e "\e[0;49;32mCandidate branch:\e[0m    `git rev-parse --abbrev-ref HEAD`"

        gitDiffInd=`git diff-index HEAD -- `
        if [[ -z $gitDiffInd ]]; then 
            echo -e "\e[0;49;32mTesting commit:\e[0m"
            git log -n1 | cat
        else 
            echo  -e "\e[0;49;32mTesting uncommitted changes.\e[0m"
        fi
        cd - >/dev/null 2>&1
    fi
fi


echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mcompile.sh:\e[0m"
echo -e "\e[0;49;32mQuestion: Does candidate binary compile?\e[0m"    
echo "Compiling with $WRF_HYDRO_COMPILER"
if [[ -z $candidateLocalPath ]]; then
    cd $candidateRepoDir/trunk/NDHMS/ || \
	{ echo "Unale to cd to $candidateRepoDir/trunk/NDHMS/. Exiting."; exit 1; }
    theCompDir=$candidateRepoDir/trunk/NDHMS/
else
    cd $candidateLocalPath/trunk/NDHMS/ || \
	{ echo "Unale to cd to $candidateLocalPath/trunk/NDHMS/. Exiting."; exit 1; }
    theCompDir=$candidateLocalPath/trunk/NDHMS/
fi
echo "Compiling in $theCompDir"
echo
$toolboxDir/config_compile_NoahMP.sh || \
    { echo -e "\e[5;49;31mAnswer: Candidate binary compile failed under $WRF_HYDRO_COMPILER.\e[0m"; \
      echo "See results in $theCompDir"; 
      exit 1; 
    }
echo -e "\e[5;49;32mAnswer: Candidate binary compile successful under $WRF_HYDRO_COMPILER!\e[0m"

exit 0
