# wrf_hydro_tests: machine configuration file.
# Purpose: Log all the static information for each machine in this file. This file
#          is sourced after the candidate specification file and my rely on 
#          variables defined therein.


export WRF_HYDRO_TESTS_DIR=/home/docker/wrf_hydro_tests
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

export WRF_HYDRO_RUN=''
# Default='' will use a canned mpiRun function from the tool box.
