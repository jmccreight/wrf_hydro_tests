#!/bin/bash

theHelp='
take_test arguments:
1: candidateSpecFile: 
     Relative or absolute path to a copy of 
     wrf_hydr_tests/candidate_template.sh 
     with details for the specific candidate.
2: testFile: 
     A file specifying the test (set of 
     questions) to run on the candidate.
'
if [[ -z $1 ]] || [[ -z $2 ]]; then
    message="\e[7;49;32mtake_test.sh: Incorrect usage. Please read the following help: \e[0m"
    echo -e "$message"
    echo -e "$theHelp"
    exit 1
fi

#Convert the specification patsh to absolute paths if needed.
candidateSpecFile=`readlink -f ${1}`
testFile=`readlink -f ${2}`

# Establish the candidate variables.
source $candidateSpecFile
source ~/.wrf_hydro_tests_machine_spec.sh

# Determine log file name
## JLM TODO: seems like the name of test should be embedded in the name of the logFile.
logFile=`$WRF_HYDRO_TESTS_DIR/toolbox/make_log_file_name.sh $candidateSpecFile`

## Assume failure for this script if the first
## addition is zero, exitValue is set to zero. Aggregated after that.
exitValue=1 

#$WRF_HYDRO_TESTS_DIR/take_test_log.sh $candidateSpecFile $testFile 2>&1 | tee $logFile

horizBar='\e[7;49;32m=================================================================\e[0m'

## Boiler plate
echo
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mtake_test.sh: A wrf_hydro candidate takes a test.                \e[0m"
echo -e "$message"                                          2>&1 | tee    $logFile
echo                                                        2>&1 | tee -a $logFile
echo -e "\e[0;49;32mBoilerplate:\e[0m"                      2>&1 | tee -a $logFile
echo "Date             : `date +'%Y %h %d %H:%M:%S %Z'`"    2>&1 | tee -a $logFile
echo "User             : `whoami`"                          2>&1 | tee -a $logFile
echo "Machine          : $HOSTNAME"                         2>&1 | tee -a $logFile
echo "candidateSpecFile: $candidateSpecFile"                2>&1 | tee -a $logFile
echo "testFile         : $testFile"                         2>&1 | tee -a $logFile  
echo "Log file         : $logFile"                          2>&1 | tee -a $logFile       
echo "Will echo candidateSpecFile to log at end."           2>&1 | tee -a $logFile

echo                                                        2>&1 | tee -a $logFile
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mSetting up the candidate                                         \e[0m"
echo -e "$message"                                          2>&1 | tee -a $logFile
source $WRF_HYDRO_TESTS_DIR/setup.sh


exit 99

echo                                                        2>&1 | tee -a $logFile
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mTesting the candidate                                            \e[0m"
echo -e "$message"                                          2>&1 | tee -a $logFile
$testFile                                                   2>&1 | tee -a $logFile
## The following is how you get a return status in spite of tee.
testExitValue=${PIPESTATUS[0]}

echo                                                        2>&1 | tee -a $logFile
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mResults of all tests.                                            \e[0m"
echo -e "$message"                                          2>&1 | tee -a $logFile
if [[ $testExitValue -ne 0 ]]; then
    message="\e[5;49;31mA total of $testExitValue tests failed.\e[0m"
else 
    message="\e[5;49;32mAll test appear successful.\e[0m"
fi
echo -e "$message"                                          2>&1 | tee -a $logFile
if [[ $? == 0 ]]; then exitValue=0; else exitValue=$testExitValue; fi

echo                                                        2>&1 | tee -a $logFile
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mTaking down the candidate.                                       \e[0m"
echo -e "$message"                                          2>&1 | tee -a $logFile
#$WRF_HYDRO_TESTS_DIR/take_down.sh                           2>&1 | tee -a $logFile

echo                                                        2>&1 | tee -a $logFile
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mLogging the candidateSpecFile.                                   \e[0m"
echo -e "$message"                                          2>&1 | tee -a $logFile
cat $candidateSpecFile                                      >> $logFile

echo                                                        2>&1 | tee -a $logFile
echo -e "$horizBar"                                         2>&1 | tee -a $logFile
message="\e[7;49;32mCandidate testing complete.                                      \e[0m"
echo -e "$message"                                          2>&1 | tee -a $logFile
exitValue=$(($?+$exitValue))

exit $exitValue
