#!/bin/bash
# Example of how to take_test
# Under normal circumstances, this invokation
# would just happen on the command line. 

# The following is strongly suggested for your ~/.bashrc, where 
# you specify the absolute path to take_test.sh on dependent on
# your location of wrf_hydro_tests.
#function take_test { /glade/u/home/`whoami`/some_path/wrf_hydro_tests/take_test.sh $@; }
WRF_HYDRO_TESTS_DIR=`readlink -e ../../../../../`
function take_test { $WRF_HYDRO_TESTS_DIR/take_test.sh $@; }


## Should always pass or the model is not deterministic.
docker run -it \
    -v $WRF_HYDRO_TESTS_DIR:/wrf_hydro_tests \
    -e WRF_HYDRO_TESTS_DIR=/wrf_hydro_tests \
    -e GITHUB_USERNAME=$GITHUB_USERNAME \
    -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
    wrfhydro/domains:sixmile \
    /wrf_hydro_tests/take_test.sh \
    /wrf_hydro_tests/examples/nwm_ana/sixmile/docker/origin_reg-upstream/how_to_take_test_fundamental-regress-v1-2_GNU.sh \
    /wrf_hydro_tests/tests/fundamental.sh

exit $?
