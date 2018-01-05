#!/bin/bash

## souce this script.

## requires envionment variable:
## testName=testName
## this is the name of the test subdirectory in
## wrf_hydro_tests/tests/$testName

testPath=$WRF_HYDRO_TESTS_DIR/tests/$testName

## check that this test exists

#configure the tests
source $testPath/config.sh

## multiple sections in the test
source $testPath/testSections.sh compile
source $testPath/testSections.sh run
source $testPath/testSections.sh restart
source $testPath/testSections.sh ncores

## TODO JLM: clean up.

echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[5;42;30mAll tests passed!\e[0m"

