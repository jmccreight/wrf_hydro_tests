#!/bin/bash

## The questions
$WRF_HYDRO_TESTS_DIR/questions/compile.sh
$WRF_HYDRO_TESTS_DIR/questions/run.sh
$WRF_HYDRO_TESTS_DIR/questions/number_of_cores.sh
$WRF_HYDRO_TESTS_DIR/questions/regression.sh
# CHANGED THE ORDER TO MAKE THIS ONE LAST
$WRF_HYDRO_TESTS_DIR/questions/perfect_restart.sh


 
