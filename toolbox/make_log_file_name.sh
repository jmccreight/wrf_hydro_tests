#!/bin/bash
# source this 
echo $candidateSpec | egrep '.sh$' > /dev/null 2>&1
if [[ "$?" -eq 0 ]]; then
    logFile=$(echo gol`echo $candidateSpec | rev | cut -c3-` | rev)
else
    logFile=${candidateSpec}.log
fi

