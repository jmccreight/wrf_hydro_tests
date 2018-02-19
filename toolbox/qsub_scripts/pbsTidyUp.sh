#!/bin/bash

# $1 = PBS_JOBID
# $2 = runDir
# The ultimate output file will have already been written by the 
# job so that date tag matches.

whtPath=`grep "wrf_hydro_tools=" ~/.wrf_hydro_tools | cut -d '=' -f2 | tr -d ' '`

${whtPath}/utilities/tracejobToFile.sh $@


numJobId=`echo $1 | cut -d'.' -f1`

## move the pbs std out and error to the files with 
## complete proper names

## if the run directory was not the working dir
if [[ ! "${2}" == './' ]]; then
    #echo "2: $2"
    
    ## move the tracejob file
    traceFile=`ls *.${numJobId}.tracejob`
    echo $traceFile 
    mv ${traceFile} ${2}/${traceFile}

    completePbsOut=`ls ${2}/.*.${numJobId}.stdout`
    dateTimeId=`echo $completePbsOut | cut -d'.' -f2`
    mv .${dateTimeId}.pbs.stdout ${2}/.${dateTimeId}.${numJobId}.stdout
    mv .${dateTimeId}.pbs.stderr ${2}/.${dateTimeId}.${numJobId}.stderr
    mv ${2}/${dateTimeId}.qCleanRun.job ${2}/${dateTimeId}.${numJobId}.qCleanRun.job
    
else 

    completePbsOut=`ls .*.${numJobId}.stdout`
    dateTimeId=`echo $completePbsOut | cut -d'.' -f2`
    mv .${dateTimeId}.pbs.stdout .${dateTimeId}.${numJobId}.stdout
    mv .${dateTimeId}.pbs.stderr .${dateTimeId}.${numJobId}.stderr
    mv ${dateTimeId}.qCleanRun.job ${dateTimeId}.${numJobId}.qCleanRun.job


fi

exit 0

