#!/bin/bash

exitValue=0

## The questions
$WRF_HYDRO_TESTS_DIR/questions/compile.sh
exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/run.sh
exitValue=$(($?+$exitValue))

#$WRF_HYDRO_TESTS_DIR/questions/perfect_restart.sh
#exitValue=$(($?+$exitValue))

#$WRF_HYDRO_TESTS_DIR/questions/number_of_cores.sh
#exitValue=$(($?+$exitValue))

#$WRF_HYDRO_TESTS_DIR/questions/regression.sh
#exitValue=$(($?+$exitValue))

$WRF_HYDRO_TESTS_DIR/questions/run-channel-only.sh
exitValue=$(($?+$exitValue))


exit $exitValue

