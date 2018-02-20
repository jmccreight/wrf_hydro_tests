# wrf_hydro_tests: machine configuration file.
# Purpose: Log all the static information for each machine in this file. This file
#          is sourced after the candidate specification file and my rely on 
#          variables defined therein.
if [[ $HOSTNAME == *cheyenne* ]]; then 

    ## Compiler
    if [[ $WRF_HYDRO_COMPILER == intel ]]; then
        export WRF_HYDRO_MODULES='intel/16.0.3 ncarenv/1.2 ncarcompilers/0.4.1 mpt/2.15f netcdf/4.4.1 nco/4.6.2 python/3.6.2'
    else 
        export WRF_HYDRO_MODULES='gnu/7.1.0 ncarenv/1.2 ncarcompilers/0.4.1 mpt/2.15 netcdf/4.4.1.1 nco/4.6.2 python/3.6.2'
    fi

    ## basic hardware
    export nCoresPerNode=36

    ## PBS/qsub defaults
    export jobNameDefault=qRunJob
    export wallTimeDefault=11:59
    export queueDefault=regular

fi
# Modules you want/need loaded on the machine.
# These are invoked all at once (order may matter) by `module load`. 
# Currently this includes modules needed for testing (e.g. on cheyenne: python and ncarenv (which contains nccmp))


export NETCDF="export NETCDF=\$(dirname `nc-config --includedir`)"
# REQUIRED
# This should not need changed for modern installs of NetCDF. Where NetCDF resides on your system. A delayed evaluation is 
# necessary only when using modules, but will work regardless. Configure script may also handle any misspecifications.


###########################################################################
# * Run group *
# How to run WRF-Hydro?
# Define a function for your machine which carries out the execution of the model. 
# The function currently takes 4 arguments, in this order, where the first 2 are required:
# nCores : integer
# binary : either full path or just the name.
# jobName: however your job scheduler/script will allow
# wallTime: however your job scheduler/script will allow
# Two examples are shown below, see notes after each.


function mpiRunFunc 
{ 
    local nCores=$1; 
    local theBinary=$2;
    dateTag=`date +'%Y-%m-%d_%H-%M-%S'`
    runCmd="mpirun -np $nCores ./`basename $theBinary` 1> ${dateTag}.stdout 2> ${dateTag}.stderr";
    echo $runCmd
    eval $runCmd 
    return $?
}
## This one covers docker. Works on cheyenne too, for small numbers of cores... for now.


function qSubFunc
{ 
    local nCores=$1; 
    local theBinary=$2;
    local jobName=$3
    local wallTime=$4
    local queue=$5
    
    # $WRF_HYDRO_TESTS_DIR comes from environment at calling time.
    local qsub_script_dir=$WRF_HYDRO_TESTS_DIR/toolbox/qsub_scripts/
    runCmd= \
        "$qsub_script_dir/q_run.sh -j $jobName -W $wallTime -q $queue $nCores ./`basename $theBinary`"
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
## This function maybe highly tailored to qsub on cheyenne.


if [[ $HOSTNAME == *cheyenne* ]]; then 
    export -f qSubFunc
    export WRF_HYDRO_RUN=qSubFunc
else 
    export -f mpiRunFunc
    export WRF_HYDRO_RUN=mpiRunFunc
fi
# REQUIRED: export -f funcName
# First the desired function must be exported.
# REQUIRED: export WRF_HYDRO_RUN=funcName
# Now call the function something generic.
# NOTE: the function on the RHS does NOT need a dollar sign.

