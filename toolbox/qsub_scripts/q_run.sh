#!/bin/bash

# $WRF_HYDRO_TESTS_DIR comes from environment.

help="
q_run :: help

Purpose/Requirements: 
Submit WRF_Hydro jobs to qsub with the following standardizations:
1) Required: You default PBS header info (mMA) in your ~/.wrf_hydro_tests_user_spec 
2) Required: -W HH:MM  wall time in HH:MM (no need for seconds)
3) log model stdout and stderr to disk and not the limited qsub buffer
   (you can read the model stderr and stdout in real-time)
4) 
5) arg 1: number of cores (not number of nodes)
7) use the following conventions for a given pbs job id which interact
   with other wrf_hydro_tools functions (cleanup, catlast)
   the job file submiited to qsub    :  YYYY-mm-dd_HH-MM-SS.jjjjjjj.q_run.job
   standard out   from the exectuable:  YYYY-mm-dd_HH-MM-SS.jjjjjjj.stdout
   standard error from the exectuable:  YYYY-mm-dd_HH-MM-SS.jjjjjjj.stderr
   standard out   from the qsub      :  YYYY-mm-dd_HH-MM-SS.pbs.stdout
   standard error from the qsub      :  YYYY-mm-dd_HH-MM-SS.pbs.stderr
   tracejob output at end of job     :  2017-mm-dd_HH-MM-SS.jjjjjjj.tracejob

## The following functionality and more are removed from the wrf_hydro_tests version
X) optionally specify a new run directory for the run 
X) option for exit script

Examples: 

## 'Vanilla'
q_run -j someJob -W00:20 720 wrf_hydro.exe

## Run in economy and run in the new_run_dir
q_run -j econJob -W00:20 -qeconomy 360 wrf_hydro.exe new_run_dir

Other header items to qsub may need adjusted on an individual basis.

Arguments as for cleanRun...
$cleanRunHelp
"

while getopts ":j:W:q:" opt; do
    case $opt in
        j) jobName="${OPTARG}" ;;
        W) wallTime="${OPTARG}" ;;
        q) queue="${OPTARG}" ;;
        \?) echo "Invalid option, exiting: -$OPTARG"
            exit 1 ;;
    esac 
done
shift "$((OPTIND-1))" # Shift off the option

if [ -z $1 ] | [ -z $2 ]; then
    echo "q_run requires 2 arguments: "
    echo "  1) # of cores"
    echo "  2) a wrf-hydro binary"    
    exit 1
fi
nCores=$1
theBinary=$2

## Verify that the number of cores is integer in a reasonable range
[[ $nCores -gt 0 ]] > /dev/null 2>&1 || { \
    echo "Number of cores not in valid range. Exiting.";
    exit 1;
}
[[ $nCores -lt 1000000 ]] > /dev/null 2>&1 ||  { \
    echo "Number of cores not in valid range. Exiting.";
    exit 1;
}

## Verify the binary in some measure
ldd $theBinary > /dev/null 2>&1 ||  { \
    echo "The passed binary does not appear to be an executable. Exiting.";
    exit 1;
}
   
function ceiling_div() {
    echo "($1 + $2 - 1)/$2" | bc; 
}

IFS=$'\n'
nNodes=`ceiling_div $nCores ${nCoresPerNode}`
nNodesM1=`echo "$nNodes - 1" | bc`
nCoresUnif=`echo "$nNodesM1*${nCoresPerNode}" | bc`
nCoresLeft=`echo "$nCores - $nCoresUnif" | bc`

if [ -z $jobName ]; then 
    if [[ -z $jobNameDefault ]]; then
        echo No jobNameDefault set for this machine in the machine_spec.sh file. Exiting.
        exit 1
    fi
    jobName=${jobNameDefault};         
fi
if [ -z $wallTime ]; then 
    if [[ -z $wallTimeDefault ]]; then
        echo No wallTimeDefault set for this machine in the machine_spec.sh file. Exiting.
        exit 1
    fi
    wallTime=${wallTimeDefault}; 
fi
if [ -z $queue ]; then 
    if [[ -z $queueDefault ]]; then
        echo No queueDefault set for this machine in the machine_spec.sh file. Exiting.
        exit 1
    fi
    queue=${queueDefault}; 
fi

echo
echo "nCores   = $nCores"
echo "nNodes   = $nNodes"
echo "jobName  = $jobName"
echo "wallTime = $wallTime"
echo "queue    = $queue"

workingDir=`pwd`/

## Do it in whatever the TZ env setting is... 
theDate=`date '+%Y-%m-%d_%H-%M-%S'`
jobFile=$theDate.q_run.job

if [[ -z $WRF_HYDRO_TESTS_USER_SPEC ]]; then
    echo "The WRF_HYDRO_TESTS_USER_SPEC env var is not specified. Exiting."
    exit 1
fi
qsubHeader=`egrep '^#PBS' $WRF_HYDRO_TESTS_USER_SPEC`
qsubHeader=`echo "$(eval "echo \"$qsubHeader\"")"`

projCode=`echo "$qsubHeader" | grep '\-A' | cut -d' ' -f3`
echo "project  = $projCode"
echo 

echo "#!/bin/bash
$qsubHeader
#PBS -N $jobName
#PBS -l walltime=${wallTime}:00
#PBS -q $queue
#PBS -l select=${nNodesM1}:ncpus=36:mpiprocs=36+1:ncpus=${nCoresLeft}:mpiprocs=${nCoresLeft}
## Not using PBS standard error and out files to capture model output
## but these hidden files might catch output and errors from the scheduler.
#PBS -o ${workingDir}/.${theDate}.pbs.stdout
#PBS -e ${workingDir}/.${theDate}.pbs.stderr

numJobId=\`echo \${PBS_JOBID} | cut -d'.' -f1\`
echo PBS_JOBID:  \$PBS_JOBID
echo numJobId: \$numJobId

## To communicate where the stderr/out and job scripts are and their ID
export cleanRunDateId=${theDate}

cd $workingDir
echo `pwd`

## WTF, this was not previously necessary
#module load mpt/2.15  

numJobId=\$(echo \${PBS_JOBID} | cut -d'.' -f1)
echo \"mpiexec_mpt $theBinary 2> \${cleanRunDateId}.\${numJobId}.stderr 1> \${cleanRunDateId}.\${numJobId}.stdout\"
mpiexec_mpt $theBinary 2> \${cleanRunDateId}.\${numJobId}.stderr 1> \${cleanRunDateId}.\${numJobId}.stdout

mpiExecReturn=\$?
echo \"mpiexec_mpt return: \$mpiExecReturn\"

# Touch these files just to get the cleanRunDateId in their file names. 
# Can identify the files by jobId and replace contents... 
touch ${workingDir}/\${cleanRunDateId}.\${numJobId}.tracejob
touch ${workingDir}/.\${cleanRunDateId}.\${numJobId}.stdout
touch ${workingDir}/.\${cleanRunDateId}.\${numJobId}.stderr

exit \$mpiExecReturn" > $jobFile

jobId=`qsub $jobFile`
echo "PBS_JOBID: $jobId"

# Background the cleanup and resource summary.
${WRF_HYDRO_TESTS_DIR}/toolbox/qsub_scripts/pbsTidyUp.sh "$jobId" "$runDir" > /dev/null 2>&1 &

unset cleanRunDateId

exit 0
