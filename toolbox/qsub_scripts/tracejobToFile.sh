#!/bin/bash

# $1 = PBS_JOBID
# $2 = runDir
# The ultimate output file will have already been written by the 
# job so that date tag matches.

grepResult=`qstat $1 2>&1 | head -n1 | grep 'finish'`
while [[ -z "$grepResult" ]]; do
    sleep 5
    grepResult=`qstat $1 2>&1 | head -n1 | grep 'finish'`
done

numJobId=`echo $1 | cut -d'.' -f1`
traceFile=`ls ${2}/*.${numJobId}.tracejob`
#echo $traceFile 
if [[ $? -eq 0 ]]; then 
    tracejob $1 > $traceFile
else 
    tracejob $1 > ${2}/${1}.tracejob
fi 

exit 0
