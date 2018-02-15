#!/bin/bash

# Purpose:
# * Execute tests on the docker wrfhydro/domains:sixmile container.
# * Use the current wrf_hydro_tests upstream/master for testing.
# * Test code which is in remote repositories (on github).
# * Use the candidate_spec_GNU.sh file in this directory.
# * Capture the test log in this directory.

# Details:
# * To pull private repos (e.g. wrf_hydro_nwm) we must specify the github
#   username and authtoken to the docker environment. These are passed
#   using the '-e' flag. See the README.md file for details on getting
#   these in your HOST environment so they can be passed. Note that in
#   machine_spec.sh file in this directory, these variables are not
#   set. The take_test.sh file gets them from the environment. 
# * To use the candidate and machine specification files in the current
#   directory and to capture the test log, we have to to mount the
#   current directory. This is done with the '-v' flag. We choose the
#   target directory on docker to be '/test_specs_logs' and we must
#   use that path when supplying the candidate file to take_test.
# * The '/bin/bash -c' usage is required because we have more than a
#   single command to pass to docker.

## Make sure your container with the sixmile domain is up-to-date
#docker pull wrfhydro/domains:sixmile

WRF_HYDRO_TESTS_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests
WRF_HYDRO_NWM_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork/

# Call docker with the appropriate arguments.
docker run -it \
       -e GITHUB_USERNAME=$GITHUB_USERNAME \
       -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
       -v $WRF_HYDRO_TESTS_DIR:/wrf_hydro_tests \
       -v `pwd`:/test_specs_logs \
       -v $WRF_HYDRO_NWM_DIR:/wrf_hydro_nwm \
       wrfhydro/domains:sixmile \
       /wrf_hydro_tests/take_test.sh \
       /test_specs_logs/candidate_spec_GNU.sh \
       fundamental-channel-only-development

exit $?
