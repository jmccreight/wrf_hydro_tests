#!/bin/bash
## Example of calling standard test.
## Docker invocation using the wrfhydro/dev container. 
## Mounted volume paths will need adjusted to your machine. 

testsDir=/glade/u/home/jamesmcc/WRF_Hydro/wrf_hydro_tests/

## Should always pass or the model is not deterministic.
$testsDir/take_test.sh \
    $testsDir/examples/upstream_master/candidate_jamesmcc_nwm-ana_cheyenne_sixmile_intel.sh \
    /glade/u/home/jamesmcc/WRF_Hydro/wrf_hydro_tests/examples/upstream_master/test_fundamental-regress-v1-2-release-gwFix-qstrmvolrtFix.sh

exit $?
