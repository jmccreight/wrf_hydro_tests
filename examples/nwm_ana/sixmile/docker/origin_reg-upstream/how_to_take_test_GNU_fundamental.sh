#!/bin/bash

docker pull wrfhydro/domains:sixmile

export WRF_HYDRO_TESTS_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/

## Should always pass or the model is not deterministic.
docker run -it \
       -v $WRF_HYDRO_TESTS_DIR:/wrf_hydro_tests \
       -e GITHUB_USERNAME=$GITHUB_USERNAME \
       -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
       wrfhydro/domains:sixmile \
       /wrf_hydro_tests/take_test.sh \
       /wrf_hydro_tests/examples/nwm_ana/sixmile/docker/origin_reg-upstream/candidate_spec_GNU.sh \
       fundamental

exit $?
