#!/bin/bash

# $1 = PBS_JOBID
# $2 = runDir
# The ultimate output file will have already been written by the 
# job so that date tag matches.


${WRF_HYDRO_TESTS_DIR}/toolbox/qsub_scripts/tracejobToFile.sh $@

numJobId=`echo $1 | cut -d'.' -f1`

## In wrf_hydro_tests, we force the run dir to be pwd.
completePbsOut=`ls .*.${numJobId}.stdout`
dateTimeId=`echo $completePbsOut | cut -d'.' -f2`
mv .${dateTimeId}.pbs.stdout .${dateTimeId}.${numJobId}.stdout
mv .${dateTimeId}.pbs.stderr .${dateTimeId}.${numJobId}.stderr
mv ${dateTimeId}.q_run.job ${dateTimeId}.${numJobId}.q_run.job

exit 0

