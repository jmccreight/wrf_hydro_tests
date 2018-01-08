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

$WRF_HYDRO_TESTS_DIR/take_test_log.sh $candidateSpec $testFile 2>&1 | tee $logFile

returnValue=$?

echo "-----------------------------------------------------------------"  >> $logFile
echo "Loggin the candidateSpec file: "  >> $logFile
cat $candidateSpec >> $logFile

exit $returnValue
