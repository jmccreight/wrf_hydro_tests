#!/bin/bash

# How to run WRF-Hydro?
# Define a function for your machine which carries out the execution of the model. 
# The function currently takes 4 arguments, in this order, where the first 2 are required:
# nCores : integer
# binary : either full path or just the name.
# jobName: however your job scheduler/script will allow
# wallTime: however your job scheduler/script will allow
# Two examples are shown below, see notes after each.

# This one covers docker. Works on cheyenne too, for small numbers of cores... for now.
# TODO JLM: differences with -np and -ppn?? Do we need to sort those out somehow?

function mpiRunFunc 
{ 
    local nCores=$1; 
    local theBinary=$2;
    dateTag=`date +'%Y-%m-%d_%H-%M-%S'`
    runCmd="mpirun -ppn $nCores ./`basename $theBinary` 1> ${dateTag}.stdout 2> ${dateTag}.stderr";
    echo $runCmd
    eval $runCmd 
    return $?
}

# Post foo
# REQUIRED: export -f funcName
# First the desired function must be exported.
# REQUIRED: export WRF_HYDRO_RUN=funcName
# Now call the function something generic.
# NOTE: the function on the RHS does NOT need a dollar sign.
