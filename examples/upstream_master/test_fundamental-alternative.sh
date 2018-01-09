#!/bin/bash

exitValue=0

## WRF-Hydro can not compile in docker on a host-mounted volume. 
## This is a hack solution to that problem
mkdir /home/docker/test_repos
candidateLocalPath_ORIG=$candidateLocalPath
candidateLocalPath=/home/docker/test_repos/candidate
cp -r $candidateLocalPath_ORIG $candidateLocalPath
referenceLocalPath_ORIG=$referenceLocalPath
referenceLocalPath=/home/docker/test_repos/reference
cp -r $referenceLocalPath_ORIG $referenceLocalPath

## The questions
$WRF_HYDRO_TESTS_DIR/questions/compile.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/run.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/perfect_restart.sh
exitValue=$(($?+$exitValue))

#$WRF_HYDRO_TESTS_DIR/questions/number_of_cores.sh
#exitValue=$(($?+$exitValue))

#$WRF_HYDRO_TESTS_DIR/questions/regression.sh
#exitValue=$(($?+$exitValue))

rm -rf $referenceLocalPath $candidateLocalPath 

exit $exitValue


