#!/bin/bash

# Arguments
# 1: candidate
# 2: test
candidateSpec=${1}
testFile=${2}

## Establish the variables
source $candidateSpec

# Setup logging
source $WRF_HYDRO_TESTS_DIR/toolbox/make_log_file_name.sh

echo -e "take_test.sh: A wrf_hydro candidate takes a test." 2>&1 | tee $logFile
echo candidateSpec: $candidateSpec  2>&1 | tee -a $logFile
echo testFile:      $testFile       2>&1 | tee -a $logFile
echo Log file:      $logFile        2>&1 | tee -a $logFile

## Log the time
date +'%Y %h %d %H:%M:%S %Z' 2>&1 | tee -a $logFile

echo "Echoing candidateSpec file to log. "  2>&1 | tee -a $logFile
cat $candidateSpec >> $logFile

echo "Setting up the candidate"  2>&1 | tee -a $logFile
source $WRF_HYDRO_TESTS_DIR/setup.sh 2>&1 | tee -a $logFile 

echo "Testing the candidate"  2>&1 | tee -a $logFile
source $testFile  2>&1 | tee -a $logFile

echo 2>&1 | tee -a $logFile
echo -e "\e[0;49;32m-----------------------------------\e[0m" 2>&1 | tee -a $logFile
echo -e "\e[5;42;30mTest was aced!\e[0m" 2>&1 | tee -a $logFile

echo "Taking down the candidate"  2>&1 | tee -a $logFile
source $WRF_HYDRO_TESTS_DIR/take_down.sh 2>&1 | tee -a $logFile

exit 0
