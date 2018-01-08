#!/bin/bash

## Test candidate template
## Purpose: collect all the necessary  variables for describing what is being tested and how.
## TODO JLM: Sourcing vs. Executing
## TODO JLM: Respect any environment variables above the scope of this file? Is that a group? 

###################################
## Required Variables:
###################################

# ** Test (broad) description group **
# A valid subdirectory of wrf_hydro_tests/tests where desired test lives.
export testName=''
# Where the domain and pre-established run directories live.
export domainSourceDir=''

# ** Machine Group **
# The local path to the wrf_hydro_tests dir.
export WRF_HYDRO_TESTS_DIR=''
# Required if you need something other than 'mpirun'
## TODO JLM: This probably has access to internal variables used by deferred execution (double quotes required?)
export RUN_WRF_HYDRO=""
# Where NetCDF resides on your system
export NETCDF=''

# ** Model group: **
# Compile time option to the model (1 for off-line runs). These are not all technically required, but
# probably a good idea to be explicit.
# Caveat Emptor:  there is nothing sacred about whatever values you may find here. 
export WRF_HYDRO=1
export HYDRO_D=0
export SPATIAL_SOIL=1
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export WRF_HYDRO_RAPID=0
export HYDRO_REALTIME=0
export NCEP_WCOSS=0
export WRF_HYDRO_NUDGING=1

# ** Number of cores group **
# default number of cores to use for runs
export nCoresDefault=2
# A different number of cores than above for performing an mpi number of cores test.
export nCoresTest=1

###################################
## Required Variables if NOT
## running in docker (i.e. locally)
###################################
# If not running in Docker, clone the domainSourceDir to domainRunDir to keep the original clean.
# !!! NOTE THAT IF YOU ARE USING A MOUNTED VOLUME IN DOCKER, YOU PROBABLY WANT TO USE THIS, !!!
# !!! HOWEVER IT IS NOT REQUIRED (UNTIL WE CAN DETECT HOST-MOUNTED DRIVES IN THE CONTAINER).!!!
export domainRunDir=''


###################################
## Optional Variables:
###################################

# ** Github group **
# If cloning repositories from github, these are required.
# See README.md for information and a suggestion on setting these. These can be inherited from the environment
export GITHUB_USERNAME=''
export GITHUB_AUTHTOKEN=''
# Where temporary repositories cloned from github shall be placed (in subfolders candidate/ and reference/)
export REPO_DIR=''

# ** Candidate repo group **
# Candidate repository is the one you have been working on. It may come from github or a local path.
# A named fork on github. Default = ${GITHUB_USERNAME}/wrf_hydro_nwm
export candidateFork=''
# A branch or commit on candidateFork. Default = master
export candidateBranchCommit=''
# --- OR ---
# A path on local machine where the current state of the repo (potentially uncommitted) is compiled.
# This supercedes BOTH candidateFork and candidateBranchCommit if set. Default =''
export candidateLocalPath=''

# ** Reference repo group **
# Optional, but necessary for regression testing.
# Reference repository is the one that provides the reference for regression testing. It may come
# from github or a local path.
# A named fork on github. Default = NCAR/wrf_hydro_nwm.
# If both referenceFork and referenceLocalPath equal '', the reference fork is not used.
export referenceFork=''
# A branch or commit on referenceFork. Default = master
export referenceBranchCommit=''
# --- OR ---
# A path on local machine where the current state of the repo (potentially uncommitted) is compiled.
# This supercedes BOTH referenceFork and referenceBranchCommit if set. Default =''
export referenceLocalPath=''
