
## Should always pass or the model is not deterministic.
## docker invocation using the wrfhydro/dev container
docker run -it \
    -v /Users/`whoami`/Downloads:/Downloads \
    -v /Users/`whoami`/WRF_Hydro/wrf_hydro_tests/:/wrf_hydro_tests \
    -e GITHUB_USERNAME=$GITHUB_USERNAME \
    -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
    wrfhydro/dev \
    /wrf_hydro_tests/take_test.sh \
    /wrf_hydro_tests/examples/docker.fundamental/candidate_jlm_master_sixmile_docker.sh \
    /wrf_hydro_tests/tests/fundamental.sh
