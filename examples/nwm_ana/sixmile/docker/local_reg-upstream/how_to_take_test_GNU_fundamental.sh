#!/bin/bash

docker pull wrfhydro/domains:sixmile

export WRF_HYDRO_NWM_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork/
export authInfo=${GITHUB_USERNAME}:${GITHUB_AUTHTOKEN}

docker run -it \
       -v `pwd`:/test_specs_logs \
       -v $WRF_HYDRO_NWM_DIR:/wrf_hydro_nwm \
       -e GITHUB_USERNAME=$GITHUB_USERNAME \
       -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
       wrfhydro/domains:sixmile \
       /bin/bash -c "git clone https://${authInfo}@github.com/NCAR/wrf_hydro_tests.git /wrf_hydro_tests; \
       /wrf_hydro_tests/take_test.sh \
       /test_specs_logs/candidate_spec_GNU.sh \
       fundamental"

exit $?
