#!/bin/bash

# Arguments
# 1: candidate
# 2: test
candidateSpec=${1}
testFile=${2}

## Establish the variables
source $candidateSpec

source $WRF_HYDRO_TESTS_DIR/setup.sh

source $testFile

echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[5;42;30mTest was aced!\e[0m"

source $WRF_HYDRO_TESTS_DIR/take_down.sh

exit 0
