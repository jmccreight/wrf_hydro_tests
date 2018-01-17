#!/bin/bash

## Test candidate template
## Purpose: collect all the necessary  variables for describing what is being tested and how.

###############################################
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## Rules for editing:
## To keep this working:
## 1) This is bash.
## 2) DO NOT REMOVE ANY export STATEMENTS
## 3) DO NOT PUT SPACES BEFORE OR AFTER ANY '='.
## We may try to relax these in the future, but this is 
## what we have for now.
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
###############################################

###############################################
## REQUIREMENTS FOR ACCEPTIBLE TEST LOGS
## 1) Document every dependency here. Do NOT pull from 
##    envionment variables in your shell. 
## 2) Name this file with the following conventions
##    candidate_$candidateFork_$candidateBranchCommit_`whoami`_model-config-name_$HOSTNAME_$domain_$compiler.sh
## TODOJLM: create a script that auto-generates file name from a source file and copies the source file to that name. 
## TODOJLM: create a script that checks if the file name matches the variables in the file.
###############################################

## Notes:
## Comments are BELOW variables.

# ** Domain Group **
export domainSourceDir=''
# REQUIRED
# Where the domain and pre-established run directories live.

export domainRunDir=''
# REQUIRED if NOT running in docker (i.e. locally):
# Clone the domainSourceDir to domainRunDir to keep the original clean.
# Default = domainSourceDir if on docker.
# !!! NOTE THAT IF YOU ARE USING A MOUNTED VOLUME IN DOCKER, YOU PROBABLY WANT TO USE THIS, !!!
# !!! HOWEVER IT IS NOT REQUIRED (UNTIL WE CAN DETECT HOST-MOUNTED DRIVES IN THE CONTAINER).!!!

# ** Machine Group **
export WRF_HYDRO_TESTS_DIR=''
# REQUIRED
# The local path to the wrf_hydro_tests dir.

function mpiRunFunc 
{ 
    local nCores=$1; 
    local theBinary=$2;
    echo "mpirun -np $nCores ./`basename $theBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'`";
    mpirun -np $nCores ./`basename $theBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'`;
    return $?
}
# Required
# Define a run function. The above works on docker and cheyenne (assuming low core counts and not 
# using the job scheduler).

export -f mpiRunFunc
# REQUIRED
# First the desired function must be exported. 
export WRF_HYDRO_RUN=mpiRunFunc
# REQUIRED
# Now call the function something generic.
# NOTE: the function on the RHS does NOT need a dollar sign.

export NETCDF=''
# REQUIRED
# Where NetCDF resides on your system

export WRF_HYDRO_COMPILER='intel'
## Default = 'GNU'
## Choices are currently 'GNU' and 'intel'. (currently case-sensitive).
## TODO clarify this: Intel and GNU write this message to different files. 
## This requires that standard out under intel is writen to a file ending in "stdout"


if [[ $HOSTNAME == *cheyenne* ]]; then 
    if [[ $WRF_HYDRO_COMPILER == intel ]]; then
        WRF_HYDRO_MODULES='intel/16.0.3 ncarenv/1.2 ncarcompilers/0.4.1 mpt/2.15f netcdf/4.4.1 nco/4.6.2 python/3.6.2'
    else 
        WRF_HYDRO_MODULES='module load gnu/7.1.0 ncarenv/1.2 ncarcompilers/0.4.1 mpt/2.15 netcdf/4.4.1.1 nco/4.6.2 python/3.6.2'
    fi
fi
# Modules you want/need loaded on the machine.
# These are invoked all at once (order may matter) by `module load`. 
# Currently this includes modules needed for testing (e.g. on cheyenne: python and ncarenv (which contains nccmp))


# ** Model group: **
export WRF_HYDRO=1
export HYDRO_D=0
export SPATIAL_SOIL=1
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_HYDRO_RAPID=0
export HYDRO_REALTIME=0
export NCEP_WCOSS=0
export WRF_HYDRO_NUDGING=1
# REQUIRED
# Compile time options to the model
# Caveat Emptor:  there is nothing sacred about whatever values you may find here. 

# ** Number of cores group **
export nCoresDefault=2
# REQUIRED
# default number of cores to use for runs
export nCoresTest=1
# REQUIRED for # cores tests.
# A different number of cores than above for performing an mpi number of cores test.

# ** Github group **
export GITHUB_USERNAME=''
export GITHUB_AUTHTOKEN=''
# REQUIRED only if cloning any repositories from github.
# See wrf_hydro_tests/README.md for information and a suggestion on setting these. These can be inherited from the environment

export REPO_DIR=''
# Where temporary repositories cloned from github shall be placed (in subfolders candidate/ and reference/)

# ** Candidate repo group **
export candidateFork=''
# Default = ${GITHUB_USERNAME}/wrf_hydro_nwm
# Candidate repository is the one you have been working on. It may come from github or a local path.
# A named fork on github. 
export candidateBranchCommit=''
# Default = master
# A branch or commit on candidateFork. 
# --- OR ---
export candidateLocalPath=''
# Default ='' : NOT used.
# A path on local machine where the current state of the repo (potentially uncommitted) is compiled.
# This supercedes BOTH candidateFork and candidateBranchCommit if set. 

# ** Reference repo group **
# REQUIRED only for regression testing.
export referenceFork=''
# Default = NCAR/wrf_hydro_nwm.
# A named fork on github. 
# Reference repository is the one that provides the reference for regression testing. It may come
# from github or a local path.
# If both referenceFork and referenceLocalPath equal '', the reference fork is not used (no regression testing).
export referenceBranchCommit=''
# Default = master
# A branch or commit on referenceFork. 
# --- OR ---
export referenceLocalPath=''
# Default ='' : NOT used.
# A path on local machine where the current state of the repo (potentially uncommitted) is compiled.
# This supercedes BOTH referenceFork and referenceBranchCommit if set. 
