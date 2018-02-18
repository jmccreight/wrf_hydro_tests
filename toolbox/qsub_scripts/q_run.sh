#!/bin/bash

# $WRF_HYDRO_TESTS_DIR comes from environment.

help="
qCleanRun :: help

Purpose: 
Submit jobs (typically wrf-hydro) to qsub with the following 
standardizations:
1) pull default PBS header information from your ~/.wrf_hydro_tests_user_spec 
   file to reduce the number of arguments needed to submit a job
2) optionally specify a new run directory for the run 
3) log model stdout and stderr to disk and not the limited qsub buffer
   (you can read the model stderr and stdout in real-time)
4) specify the wall time in HH:MM (no need for seconds)
5) arg 1: number of cores (not number of nodes)
6) option for exit script
7) use the following conventions for a given pbs job id which interact
   with other wrf_hydro_tools functions (cleanup, catlast)
   the job file submiited to qsub    :  YYYY-mm-dd_HH-MM-SS.jjjjjjj.qCleanRun.job
   standard out   from the exectuable:  YYYY-mm-dd_HH-MM-SS.jjjjjjj.stdout
   standard error from the exectuable:  YYYY-mm-dd_HH-MM-SS.jjjjjjj.stderr
   standard out   from the qsub      :  YYYY-mm-dd_HH-MM-SS.pbs.stdout
   standard error from the qsub      :  YYYY-mm-dd_HH-MM-SS.pbs.stderr
   tracejob output at end of job     :  2017-mm-dd_HH-MM-SS.jjjjjjj.tracejob
6) various options to 

Examples: 

## 'Vanilla'
qCleanRun -j someJob -W00:20 720 wrf_hydro.exe

## Run in economy and run in the new_run_dir
qCleanRun -j econJob -W00:20 -qeconomy 360 wrf_hydro.exe new_run_dir

Other header items to qsub may need adjusted on an individual basis.

Arguments as for cleanRun...
$cleanRunHelp
"

if [ -z $1 ]
then
    echo -e "\e[31mPlease pass arguments to cleanRun.\e[0m $help"
    exit 1
fi

fOpt=''
pOpt=''
uOpt=''
nOpt=''
cOpt=''
dOpt=''
oOpt=''
rOpt=''
while getopts ":fpuncdorj:e:W:q:" opt; do
    case $opt in
        j) jobName="${OPTARG}" ;;
        W) wallTime="${OPTARG}" ;;
        q) queue="${OPTARG}" ;;
        e) exitScript="${OPTARG}" ;;
        u) uOpt="-u" ;;
        c) cOpt="-c" ;;
        f) fOpt="-f" ;;
        d) dOpt="-d" ;;
        o) oOpt="-o" ;;
        n) nOpt="-n" ;;
        p) pOpt="-p" ;;
        r) rOpt="-r" ;;
        \?) echo "Invalid option, exiting: -$OPTARG"
            exit 1 ;;
    esac 
done
shift "$((OPTIND-1))" # Shift off the option

allArgs="$rOpt $cOpt $fOpt $oOpt $dOpt $uOpt $nOpt $pOpt $@"
IFS=$'\n'
nCores=`echo "${@:1:1}" | bc`
nNodes=`ceiling_div $nCores 36`
nNodesM1=`echo "$nNodes - 1" | bc`
nCoresUnif=`echo "$nNodesM1*36" | bc`
nCoresLeft=`echo "$nCores - $nCoresUnif" | bc`
#echo "nNodes:     $nNodes"
#echo "nNodesM1:   $nNodesM1"
#echo "nCoresUnif: $nCoresUnif"
#echo "nCoresLeft: $nCoresLeft"
#exit 9

#echo "$allArgs"
if [ -z $jobName ]; then jobName=myRun; fi
if [ -z $wallTime ]; then wallTime=11:44; fi
if [ -z $queue ]; then queue=regular; fi
#exit 1

runDir=$3
if [[ -z "$runDir" ]]; then
    runDir='./'
fi

echo
echo "nCores   = $nCores"
echo "nNodes   = $nNodes"
echo "jobName  = $jobName"
echo "wallTime = $wallTime"
echo "queue    = $queue"

if [ ! -z $exitScript ]
then
    exitScript="./${exitScript}"
    echo Exit script: "$exitScript"
fi


## check valid options
while getopts "::fpuncdor" opt; do
    case $opt in
        \?) echo "Invalid option: -$OPTARG"
            exit 1 ;;
    esac 
done
shift "$((OPTIND-1))" # Shift off the option


workingDir=`pwd`/

## do it in local time. necessary for envs which dont source my bashrc
export TZ=America/Denver  
theDate=`date '+%Y-%m-%d_%H-%M-%S'`
jobFile=$theDate.qCleanRun.job

qsubHeader=`egrep '^#PBS' ~/.wrf_hydro_tools`
qsubHeader=`echo "$(eval "echo \"$qsubHeader\"")"`

projCode=`echo "$qsubHeader" | grep '\-A' | cut -d' ' -f3`
echo "project  = $projCode"
echo 

echo "#!/bin/bash
$qsubHeader

#qalter -o foozie.out \$PBS_JOBID
#qalter -e foozie.err \$PBS_JOBID

numJobId=\`echo \${PBS_JOBID} | cut -d'.' -f1\`
echo PBS_JOBID:  \$PBS_JOBID
echo numJobId: \$numJobId


#source ~/.bashrc
source $whtPath/utilities/helpers.sh

## To communicate where the stderr/out and job scripts are and their ID
export cleanRunDateId=${theDate}

cd $workingDir

$whtPath/utilities/cleanRun.sh ${allArgs}
modelReturn=\$?

echo \"model return: \$modelReturn\"

## Touch this dummy file just to get the cleanRunDateId in the file name. Can  
## identify these file by jobId and replace contents
touch ${runDir}/\${cleanRunDateId}.\${numJobId}.tracejob
touch ${runDir}/.\${cleanRunDateId}.\${numJobId}.stdout
touch ${runDir}/.\${cleanRunDateId}.\${numJobId}.stderr

$exitScript

exit \$modelReturn" > $jobFile

#echo ---
#cat $jobFile
#exit 1

jobId=`qsub $jobFile`
echo "PBS_JOBID: $jobId"
${whtPath}/utilities/pbsTidyUp.sh "$jobId" "$runDir" > /dev/null 2>&1 &

unset cleanRunDateId


exit 0
