#!/bin/bash

# $1 = PBS_JOBID
# The ultimate output file will have already been written by the 
# job so that date tag matches.

grepResult=`qstat $1 2>&1 | head -n1 | grep 'finish'`
while [[ -z "$grepResult" ]]; do
    sleep 5
    grepResult=`qstat $1 2>&1 | head -n1 | grep 'finish'`
done

numJobId=`echo $1 | cut -d'.' -f1`
traceFile=`ls *.${numJobId}.tracejob`
echo $traceFile 
tracejob $1 > $traceFile

exit 0
