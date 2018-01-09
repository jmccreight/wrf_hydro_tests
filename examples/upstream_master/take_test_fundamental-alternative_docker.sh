## Example of constructing your own alternative test. 
## Docker invocation using the wrfhydro/dev container. 
## Mounted volume paths will need adjusted to your machine. 

## This test should always pass or the model is not deterministic.
docker run -it \
    -v /Users/`whoami`/Downloads:/Downloads \
    -v /Users/`whoami`/WRF_Hydro/wrf_hydro_tests/:/wrf_hydro_tests \
    -v /Users/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork:/wrf_hydro_nwm_myFork \
    -v /Users/jamesmcc/WRF_Hydro/wrf_hydro_nwm_myFork_2:/wrf_hydro_nwm_myFork_2 \
    -e GITHUB_USERNAME=$GITHUB_USERNAME \
    -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
    wrfhydro/dev

    /wrf_hydro_tests/take_test.sh \
    /wrf_hydro_tests/examples/upstream_master/candidate_jamesmcc_nwm-ana_docker_sixmile.sh \
    /wrf_hydro_tests/examples/upstream_master/test_fundamental-alternative.sh
