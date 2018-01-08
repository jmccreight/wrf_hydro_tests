#!/bin/bash
candidateSpecFile=$1
echo $candidateSpecFile | egrep '.sh$' > /dev/null 2>&1
if [[ "$?" -eq 0 ]]; then
    logFile=$(echo gol`echo $candidateSpecFile | rev | cut -c3-` | rev)
else
    logFile=${candidateSpecFile}.log
fi

echo $logFile

exit 0
