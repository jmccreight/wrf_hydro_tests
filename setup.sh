#!/bin/bash

## Source this script.
## After informative message: exit on failure with non-zero status.
## Do not exit otherwise.
## KEEP THIS SCRIPT AS GENERAL AS POSSIBLE FOR THE SETUP

if [[ "${1}" == '--help' ]]; then echo "$theHelp"; exit 0; fi

## Establish the file structure
## Where do all the parts live for the test?
export testRepoDir=$REPO_DIR/test
export refRepoDir=$REPO_DIR/reference

export toolboxDir=$WRF_HYDRO_TEST_DIR/wrf_hydro_test/toolbox
export answerKeyDir=$WRF_HYDRO_TEST_DIR/wrf_hydro_tests/answer_keys

#Make directories that don't exist already
## TODO JLM: action if they already exist?
## TODO JLM: tear these down in local runs? optionally?
[ -d $testRepoDir ] || mkdir -p $testRepoDir
[ -d $refRepoDir ] || mkdir -p $refRepoDir

## Clone domainTestDir for non-docker applications.
## TODO JLM: also have to tear this down? optionally?
inDocker=FALSE
if [[ -f /.dockerenv ]]; then inDocker=TRUE; fi

if [[ ! -z $domainTestDir ]]; then
    if [[ "$domainSourceDir" = /* ]]; then
	cp -as $domainSourceDir $domainTestDir
    else
	cp -as `pwd`/$domainSourceDir $domainTestDir
    fi
else
    if [[ $inDocker == "FALSE" ]]; then
	## JLM: this does not catch drives mounted from host into the docker container.
	echo "You are not in docker and you have not specified "
        echo "the \$domainTestDir environment variable. "
        echo "Exiting instead of writing into your \$domainSourceDir."
	exit 1
    fi
    export domainTestDir=$domainSourceDir
fi

###################################
##Setup github authitcation
doExit=0
if [[ -z ${GITHUB_USERNAME} ]]; then
    echo "The required environment variable GITHUB_USERNAME has 
          not been passed to the container. Please try 
          'docker run wrfhydro/testing --help' 
          for help. Exiting"
    doExit=1
fi
if [[ -z ${GITHUB_AUTHTOKEN} ]] ; then
    echo "The required environment variable GITHUB_AUTHTOKEN has 
          not been passed to the container. Please try 
          'docker run wrfhydro/testing --help' 
          for help. Exiting"
    doExit=1
fi
if [[ $doExit -eq 1 ]]; then exit 1; fi

authInfo=${GITHUB_USERNAME}:${GITHUB_AUTHTOKEN}
if [[ -z ${testFork} ]]; then testFork=${GITHUB_USERNAME}/wrf_hydro_nwm; fi
if [[ -z ${testBranchCommit} ]]; then testBranchCommit=master; fi
if [[ -z ${referenceFork} ]]; then referenceFork=NCAR/wrf_hydro_nwm; fi
if [[ -z ${referenceBranchCommit} ]]; then referenceBranchCommit=master; fi

###################################
###Clone reference fork into repos directory
cd $refRepoDir
# reference fork
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mReference fork: $referenceFork\e[0m"
git clone https://${authInfo}@github.com/$referenceFork $refRepoDir    
git checkout $referenceBranchCommit || \
    { echo "Unsuccessful checkout of $referenceBranchCommit from $referenceFork."; exit 1; }
echo -e "\e[0;49;32mRepo in\e[0m `pwd`"
echo -e "\e[0;49;32mReference branch:\e[0m    `git branch`"
echo -e "\e[0;49;32mReference commit:\e[0m"
git log -n1

###################################
## Check if running in circleCI or locally.
## This is specified using environment variables passed to docker
## If running locally, clone specified test fork, otherwise in circleCI the current PR/Commit
## is used as test.
if [[ -z ${CIRCLECI} ]]; then 
    echo
    ##Local 
    cd $testRepoDir    
    # git clone specified test fork
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: $testFork\e[0m"
    git clone https://${authInfo}@github.com/$testFork $testRepoDir
    git checkout $testBranchCommit || \
        { echo "Unsuccessful checkout of $testBranchCommit from $testFork."; exit 1; }
    echo -e "\e[0;49;32mRepo moved to\e[0m `pwd`"
    echo -e "\e[0;49;32mTest branch:\e[0m    `git branch`"
    echo -e "\e[0;49;32mTesting commit:\e[0m"
    git log -n1
    
fi

