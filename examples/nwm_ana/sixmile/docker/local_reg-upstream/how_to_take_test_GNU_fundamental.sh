#!/bin/bash

docker pull wrfhydro/domains:sixmile

export WRF_HYDRO_TESTS_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/
export WRF_HYDRO_NWM_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork/

docker run -it \
       -v $WRF_HYDRO_TESTS_DIR:/wrf_hydro_tests \
       -v $WRF_HYDRO_NWM_DIR:/wrf_hydro_nwm \
       -e GITHUB_USERNAME=$GITHUB_USERNAME \
       -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
       wrfhydro/domains:sixmile \
       /wrf_hydro_tests/take_test.sh \
       /wrf_hydro_tests/examples/nwm_ana/sixmile/docker/local_reg-upstream/candidate_spec_GNU.sh \
       fundamental

exit $?
