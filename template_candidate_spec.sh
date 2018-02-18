#!/bin/bash

# wrf_hydro_tests: Candidate specification template file.
# Purpose: Collect all the necessary  variables for describing what is being 
#          tested and how. This file works in conjunction with (and is 
#          sourced before (~/.wrf_hydro_tests_machine_spec.sh)

##############################################
# Rules for editing(to keep this working):
# 1) This is bash.
# 2) DO NOT remove any export statements
# 3) DO NOT put spaces before or after any '='.
# We will try to relax these in the future
##############################################
## Notes:
## Comments are BELOW variables.

###########################################################################
# * Machine spec file path *
export WRF_HYDRO_TESTS_MACHINE_SPEC='/test_specs_logs/machine_spec.sh'
# Default (if not set) = ~/.wrf_hydro_tests_machine_spec.sh
# We recommend the default. If using an alternative location, then
# variable consists of the path/file for the machine specification. 

# * Machine spec file path *
export WRF_HYDRO_TESTS_USER_SPEC='/test_specs_logs/machine_spec.sh'
# Default (if not set) = ~/.wrf_hydro_tests_machine_spec.sh
# We recommend the default. If using an alternative location, then
# variable consists of the path/file for the machine specification. 


###########################################################################
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


###########################################################################
# * Compiler * 

export WRF_HYDRO_COMPILER='GNU'
## Default = 'GNU'
## Choices are currently 'GNU' and 'intel'. (currently case-sensitive).


#####################################################################################


export TEST_WALL_TIME=00:05
## The wall time to use with a job scheduler.

# ** Number of cores group **
export nCoresDefault=2
# REQUIRED
# default number of cores to use for runs

export nCoresTest=1
# REQUIRED for # cores tests.
# A different number of cores than above for performing an mpi number of cores test.


###########################################################################
# * Model compile options group *

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

###########################################################################
# * Repo groups *

export REPO_DIR=''
# Where temporary repositories cloned from github shall be placed (in subfolders candidate/ and reference/)

# ** Candidate repo subgroup **

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


# ** Reference repo subgroup **
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
