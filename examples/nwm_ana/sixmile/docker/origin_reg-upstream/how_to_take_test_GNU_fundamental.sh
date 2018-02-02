#!/bin/bash

docker pull wrfhydro/domains:sixmile

export WRF_HYDRO_TESTS_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/
export authInfo=${GITHUB_USERNAME}:${GITHUB_AUTHTOKEN}

## Should always pass or the model is not deterministic.
docker run -it \
       -v `pwd`:/test_specs_logs \
       -e GITHUB_USERNAME=$GITHUB_USERNAME \
       -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
       wrfhydro/domains:sixmile \
       /bin/bash -c "git clone https://${authInfo}@github.com/NCAR/wrf_hydro_tests.git /wrf_hydro_tests; \
       /wrf_hydro_tests/take_test.sh \
       /test_specs_logs/candidate_spec_GNU.sh \
       fundamental"

exit $?
