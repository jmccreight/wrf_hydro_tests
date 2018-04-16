#!/bin/bash
## This function maybe highly tailored to qsub on cheyenne.

# How to run WRF-Hydro?
# Define a function for your machine which carries out the execution of the model. 
# The function currently takes 4 arguments, in this order, where the first 2 are required:
# nCores : integer
# binary : either full path or just the name.
# jobName: however your job scheduler/script will allow
# wallTime: however your job scheduler/script will allow
# Two examples are shown below, see notes after each.

function qSubFunc
{ 
    local nCores=$1; 
    local theBinary=$2;
    local jobName=$3
    local wallTime=$4
    local queue=$5
    
    ## Let queue be optional
    if [[ ! -z $queue ]]; then 
        queue="-q $queue"
    fi

    # $WRF_HYDRO_TESTS_DIR comes from environment at calling time.
    local qsub_script_dir=$WRF_HYDRO_TESTS_DIR/toolbox/qsub_scripts/
    runCmd="$qsub_script_dir/q_run.sh -j $jobName -W $wallTime $queue $nCores ./`basename $theBinary`"
    #$runCmd
    echo $runCmd
    scriptOutput=`eval $runCmd`
    echo "$scriptOutput"
    jobId=`echo "$scriptOutput" | grep PBS_JOBID | cut -d' ' -f2 | cut -d'.' -f1`
    echo jobId: $jobId
    if [[ -z $jobId ]]; then 
        echo "Job submission appeared to fail."
        return 1
    fi
    jobStatus='Q'
    while [ "$jobStatus" != "F" ]; do
        sleep 5
        jobStatus=`qstat -x $jobId | tail -n1 | tr -s ' ' | cut -d' ' -f5`
        #echo "jobStatus: $jobStatus"
    done
    return 0
}

# Post foo
# REQUIRED: export -f funcName
# First the desired function must be exported.
# REQUIRED: export WRF_HYDRO_RUN=funcName
# Now call the function something generic.
# NOTE: the function on the RHS does NOT need a dollar sign.
