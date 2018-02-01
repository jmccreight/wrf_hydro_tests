#!/bin/bash
candidateSpecFile=$1
testSpecFile=$2

## Purpose: Prefix the full path to the candidate spec file to the 
##          base file name of the test spec file, removing all ".sh"
##          extensions, and adding the ".log" extension.

## Note the candidate spec file retains a full path if present so 
## the log is placed in the directory with the candidate. 

## Test if the file ends in .sh
echo $candidateSpecFile | egrep '.sh$' > /dev/null 2>&1
if [[ "$?" -eq 0 ]]; then
    ## if it does, lop off the ".sh"
    logFile=$(echo `echo $candidateSpecFile | rev | cut -c4-` | rev)
fi

## Take only the basename of the testSpecFile
testSpecFile=`basename $testSpecFile`

## Test if the file ends in ".sh"
echo $testSpecFile | egrep '.sh$' > /dev/null 2>&1
if [[ "$?" -eq 0 ]]; then
    ## if it does, lop off the ".sh"
    logFile=${logFile}_test_spec_$(echo `echo $testSpecFile | rev | cut -c4-` | rev)
else 
    logFile=${logFile}_test_spec_${testSpecFile}
fi

logFile=${logFile}.log

echo $logFile

exit 0
