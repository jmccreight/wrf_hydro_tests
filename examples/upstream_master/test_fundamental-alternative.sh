#!/bin/bash

exitValue=0

## WRF-Hydro can not compile in docker on a host-mounted volume. 
## This is a hack solution to that problem

REPO_DIR=/glade/scratch/`whoami`/test_repos
REPO_DIR_ORIG=$REPO_DIR
REPO_DIR=/glade/scratch/`whoami`/test_repos

## The questions
$WRF_HYDRO_TESTS_DIR/questions/compile.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/run.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/perfect_restart.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/number_of_cores.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/regression.sh
exitValue=$(($?+$exitValue))

exit $exitValue


