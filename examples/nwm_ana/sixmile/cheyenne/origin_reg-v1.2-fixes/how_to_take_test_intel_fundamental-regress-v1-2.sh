#!/bin/bash
# Example of how to take_test
# Under normal circumstances, this invokation
# would just happen on the command line. 

# The following is strongly suggested for your ~/.bashrc, where 
# you specify the absolute path to take_test.sh on dependent on
# your location of wrf_hydro_tests. (The following is the most
# cunning fakery I can muster).
WRF_HYDRO_TESTS_DIR=`readlink -e ../../../../../`
function take_test { $WRF_HYDRO_TESTS_DIR/take_test.sh $@; }

take_test \
    candidate_spec_intel.sh \
    fundamental-regress-v1-2-release-w-upgrades

exit $?
