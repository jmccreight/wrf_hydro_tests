#!/bin/bash
# Example of how to take_test
# Under normal circumstances, this invokation
# would just happen on the command line. 

# The following is strongly suggested for your ~/.bashrc, where 
# you specify the absolute path to take_test.sh on dependent on
# your location of wrf_hydro_tests.
#function take_test { /glade/u/home/`whoami`/some_path/wrf_hydro_tests/take_test.sh $@; }
WRF_HYDRO_TESTS_DIR=`readlink -e ../../../../`
function take_test { $WRF_HYDRO_TESTS_DIR/take_test.sh $@; }

## Should always pass or the model is not deterministic.
take_test \
    candidate_spec_GNU_nwm_origin_nudging-fix_reg-origin-v1.2-updates.sh \
    fundamental-regress-v1-2-release-w-upgrades

exit $?
