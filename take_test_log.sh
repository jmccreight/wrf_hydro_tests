#!/bin/bash

# Arguments
# 1: candidate
# 2: test
candidateSpec=${1}
testFile=${2}

## Establish the variables
source $candidateSpec

# log the log file (for the benefit those looking at the screen)
source $WRF_HYDRO_TESTS_DIR/toolbox/make_log_file_name.sh

echo -e "take_test.sh: A wrf_hydro candidate takes a test."
echo
date +'%Y %h %d %H:%M:%S %Z'
echo
echo candidateSpec: $candidateSpec  
echo testFile:      $testFile       
echo Log file:      $logFile        
echo
echo "Will echo candidateSpec file to log at end."  
echo
echo "Setting up the candidate"  
source $WRF_HYDRO_TESTS_DIR/setup.sh
echo
echo "Testing the candidate"  
source $testFile  
echo
echo "Taking down the candidate"  
source $WRF_HYDRO_TESTS_DIR/take_down.sh 
echo
echo Testing complete.
exit 0
