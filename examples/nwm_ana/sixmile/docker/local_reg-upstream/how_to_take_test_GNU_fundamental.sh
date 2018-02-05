#!/bin/bash

# Purpose:
# * Execute tests on the docker wrfhydro/domains:sixmile container.
# * Use the current wrf_hydro_tests upstream/master for testing.
# * Test code which is in LOCAL a repository (NOT on github), that
#   is the code lives on your host machine.
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
# * To get a repo on the host machine into docker, we must specify
#   where the code is on the host and mount that location into the
#   docker container. We choose to mount that repo to /wrf_hydro_nwm
#   in the container.
# * The '/bin/bash -c' usage is required because we have more than a
#   single command to pass to docker.

# Make sure your container with the sixmile domain is up-to-date
docker pull wrfhydro/domains:sixmile

# You must specify the path to the LOCAL repo you wish to compile on
# the HOST machine (not docker). This must be modified to suit you.
export WRF_HYDRO_NWM_DIR=/Users/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork/

# Call docker with the appropriate arguments.
docker run -it \
       -v `pwd`:/test_specs_logs \
       -v $WRF_HYDRO_NWM_DIR:/wrf_hydro_nwm \
       -e GITHUB_USERNAME=$GITHUB_USERNAME \
       -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
       wrfhydro/domains:sixmile \
       /bin/bash -c "git clone https://${GITHUB_USERNAME}:${GITHUB_AUTHTOKEN}@github.com/NCAR/wrf_hydro_tests.git /wrf_hydro_tests; \
       /wrf_hydro_tests/take_test.sh \
       /test_specs_logs/candidate_spec_GNU.sh \
       fundamental"

exit $?
