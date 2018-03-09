#!/bin/bash

TAKE_TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
currentTestTags=\
`for i in $TAKE_TEST_DIR/tests/*.sh; do 
echo "           "$(basename $i) | rev | cut -c4- | rev; 
done`

theHelp="
take_test: help

A machine specification file is required for
every machine and should be placed in 
~/.wrf_hydro_tests_machine_spec.sh

Arguments:
1: candidateSpecFile: 
     Relative or absolute path to a copy of 
     wrf_hydr_tests/candidate_template.sh 
     with details for the specific candidate.
2: testSpec: 
     Either
     1) A file specifying the test (set of 
        questions) to run on the candidate, 
     or 
     2) A known tag for a canned test. The
        current list of tags (relative to 
        where take_test lives, not necessarily
        the same as $WRF_HYDRO_TESTS_DIR): 

$currentTestTags
"
if [[ -z $1 ]] || [[ -z $2 ]]; then
    message="\e[7;49;32mtake_test.sh: Incorrect usage. Please read the following help: \e[0m"
    echo -e "$message"
    echo -e "$theHelp"
    exit 1
fi

#Convert the specification paths to absolute paths if needed.
candidateSpecFile=`readlink -f ${1}`
testSpecFile=`readlink -e ${2}`

#######################################################
# Read the 4 specification files: candidate, machine, user, test.

# User specification, first time.
if [[ -z $WRF_HYDRO_TESTS_USER_SPEC ]]; then
    export WRF_HYDRO_TESTS_USER_SPEC=~/.wrf_hydro_tests_user_spec.sh
fi

if [[ ! -e $WRF_HYDRO_TESTS_USER_SPEC ]]; then
    echo The user spec file: $WRF_HYDRO_TESTS_USER_SPEC
    echo does not exist. Exiting.
    exit 1
fi
source $WRF_HYDRO_TESTS_USER_SPEC

## Candidate specification
## TODO: test for existence
source $candidateSpecFile

# Establish the machine specifications.
if [[ -z $WRF_HYDRO_TESTS_MACHINE_SPEC ]]; then
    export WRF_HYDRO_TESTS_MACHINE_SPEC=$WRF_HYDRO_TESTS_DIR/machine_spec.sh
fi
## TODO: test for existence
source $WRF_HYDRO_TESTS_MACHINE_SPEC

# User specification, again. 
if [[ -z $WRF_HYDRO_TESTS_USER_SPEC ]]; then
    export WRF_HYDRO_TESTS_USER_SPEC=~/.wrf_hydro_tests_user_spec.sh
fi
## TODO: test for existence
source $WRF_HYDRO_TESTS_USER_SPEC

# Does test specification testSpecFile exist? If not, does its tag yield a file in the repo?
# If $2 was not a file, then $testSpecFile will be null
if [[ ! -e $testSpecFile ]]; then
    testSpecFile=`readlink -e $WRF_HYDRO_TESTS_DIR/tests/${2}.sh`
    if [[ ! -e $testSpecFile ]]; then
        echo
        echo The second argument, the test specification, does not
        echo indicate any file. 
        echo Neither:
	echo `readlink -e ${2}`
	echo nor
	echo `readlink -e $WRF_HYDRO_TESTS_DIR/tests/${2}.sh`
	echo is a file.
        # echo "$theHelp"
	# Echoing help is potentially confusing because the $WRF_HYDRO_RESTS_DIR
	# may not match the users expectation (pulled remote vs local).
        echo Exiting. 
        exit 1
    fi
fi
#######################################################

## Now establish logging.
export logFile=`$WRF_HYDRO_TESTS_DIR/toolbox/make_log_file_name.sh $candidateSpecFile $testSpecFile`
rm -f $logFile
function echoTee { echo "$@" 2>&1 | tee -a $logFile; }


# Get the commit of the testing repo being used. 
cd $WRF_HYDRO_TESTS_DIR
whTestsCommit=`git rev-parse HEAD`
git diff-index --quiet HEAD --
whTestsUncommitted=$?
cd - > /dev/null 2>&1


# Assume failure for this script if the first
# addition is zero, exitValue is set to zero. Aggregated after that.
exitValue=1 


# Reuse this
horizBar='\e[7;49;32m=================================================================\e[0m'

## Boiler plate
echoTee
echoTee -e "$horizBar"
message="\e[7;49;32mtake_test.sh: A wrf_hydro candidate takes a test.                \e[0m"
echoTee -e "$message"
echoTee                                                          
echoTee -e "\e[0;49;32mBoilerplate:\e[0m"                        
echoTee "Date                  : `date +'%Y %h %d %H:%M:%S %Z'`" 
echoTee "User                  : `whoami`"                       
echoTee "Machine               : $HOSTNAME"                      
echoTee "wrf_hydro_tests commit: $whTestsCommit"                 
if [[ $whTestsUncommitted -eq 1 ]]; then
    echoTee "There are uncommitted changes to wrf_hydro_tests."  
fi
echoTee "machine spec file     : $WRF_HYDRO_TESTS_MACHINE_SPEC" 
echoTee "candidateSpecFile     : $candidateSpecFile"            
echoTee "testSpecFile          : $testSpecFile"                   
echoTee "Log file              : $logFile"                             
echoTee "Will echo candidateSpecFile to log at end."            

echoTee                                                       
echoTee -e "$horizBar"                                        
message="\e[7;49;32mSetting up the candidate                                         \e[0m"
echoTee -e "$message"                                         
source $WRF_HYDRO_TESTS_DIR/setup.sh

echoTee                                                       
echoTee -e "$horizBar"                                        
message="\e[7;49;32mTesting the candidate                                            \e[0m"
echoTee -e "$message"                                         
$testSpecFile                                                        2>&1 | tee -a $logFile
## The following is how you get a return status in spite of tee.
testExitValue=${PIPESTATUS[0]}

echoTee                                                       
echoTee -e "$horizBar"                                        
message="\e[7;49;32mResults of all tests.                                            \e[0m"
echoTee -e "$message"                                         
if [[ $testExitValue -ne 0 ]]; then
    message="\e[5;49;31mA total of $testExitValue tests failed.\e[0m"
else 
    message="\e[5;49;32mAll test appear successful.\e[0m"
fi
echoTee -e "$message"                                         
if [[ $? == 0 ]]; then exitValue=0; else exitValue=$testExitValue; fi

echoTee                                                       
echoTee -e "$horizBar"                                        
message="\e[7;49;32mTaking down the candidate.                                       \e[0m"
echoTee -e "$message"                                         
#$WRF_HYDRO_TESTS_DIR/take_down.sh                          

echoTee                                                       
echoTee -e "$horizBar"                                        
message="\e[7;49;32mLogging the candidateSpecFile.                                   \e[0m"
echoTee -e "$message"                                         
source $WRF_HYDRO_TESTS_DIR/toolbox/echo_candidate.sh                   >> $logFile

echoTee                                                       
echoTee -e "$horizBar"                                        
message="\e[7;49;32mCandidate testing complete.                                      \e[0m"
echoTee -e "$message"                                         
exitValue=$(($?+$exitValue))

## How to handle the exit
if [[ $inDocker == TRUE ]]; then
    if [[ $testExitValue -ne 0 ]]; then
        echoTee -e "\e[5;49;31mEntering docker interactively because some tests failed.\e[0m"
        exec /bin/bash
    else
        exit 0
    fi
else
    exit $exitValue
fi
