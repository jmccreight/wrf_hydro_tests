#!/bin/bash
# Example of how to take_test
# Under normal circumstances, this invokation
# would just happen on the command line. 

# Something like the following is strongly suggested for 
# your ~/.bashrc (or similar for your ~/.cshrc) see README 
# for more details. 
WRF_HYDRO_TESTS_DIR=`readlink -e ../../../../../`
function take_test { $WRF_HYDRO_TESTS_DIR/take_test.sh $@; }

take_test \
    candidate_spec_intel.sh \
    fundamental

exit $?
