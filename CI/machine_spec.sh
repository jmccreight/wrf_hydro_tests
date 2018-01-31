# wrf_hydro_tests: machine configuration file.
# Purpose: Log all the static information for each machine in this file. This file
#          is sourced after the candidate specification file and my rely on 
#          variables defined therein.


export WRF_HYDRO_TESTS_DIR=/wrf_hydro_ci/wrf_hydro_tests
# REQUIRED
# The local path to the wrf_hydro_tests dir.


#export GITHUB_AUTHTOKEN=`cat ~/.github_authtoken 2> /dev/null`
#export GITHUB_USERNAME=jmccreight
# Set by CircleCI web interface.

export NETCDF=$(dirname `nc-config --includedir`)
# REQUIRED
# Where NetCDF resides on your system


###########################################################################
# * Run group *
# How to run WRF-Hydro?
# Define a function for your machine which carries out the execution of the model. 
# The function currently takes 4 arguments, in this order, where the first 2 are required:
# nCores : integer
# binary : either full path or just the name.
# jobName: however your job scheduler/script will allow
# wallTime: however your job scheduler/script will allow
# Two examples are shown below, see notes after each.


function mpiRunFunc 
{ 
    local nCores=$1; 
    local theBinary=$2;
    dateTag=`date +'%Y-%m-%d_%H-%M-%S'`
    runCmd="mpirun -np $nCores ./`basename $theBinary` 1> ${dateTag}.stdout 2> ${dateTag}.stderr";
    echo $runCmd
    eval $runCmd 
    return $?
}
## This one covers docker. Works on cheyenne too, for small numbers of cores... for now.


export -f mpiRunFunc
export WRF_HYDRO_RUN=mpiRunFunc

