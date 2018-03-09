#!/bin/bash

## Source this script.
## After informative message: exit on failure with non-zero status.
## Do not exit otherwise.
## KEEP THIS SCRIPT AS GENERAL AS POSSIBLE FOR THE SETUP

###################################
## Are we in docker?
################################### 
export inDocker=FALSE
if [[ -f /.dockerenv ]]; then inDocker=TRUE; fi


###################################
## Establish the file structure
###################################
## Where do all the parts live for the test?
candidateRepoDir=$REPO_DIR/candidate
refRepoDir=$REPO_DIR/reference
## actually establish these later.

if [[ ! -z $candidateLocalPath ]] && [[ $inDocker == FALSE ]]; then
    candidateRepoDir=$candidateLocalPath
fi
if [[ ! -z $referenceLocalPath ]] && [[ $inDocker == FALSE ]]; then
    refRepoDir=$referenceLocalPath
fi

export candidateRepoDir=$candidateRepoDir
export refRepoDir=$refRepoDir

export toolboxDir=$WRF_HYDRO_TESTS_DIR/toolbox
export answerKeyDir=$WRF_HYDRO_TESTS_DIR/answer_keys

#Binary paths/names
## TODO JLM: evaluate if better names should be used. 
export candidateBinary=$candidateRepoDir/trunk/NDHMS/Run/wrf_hydro.exe
export referenceBinary=$refRepoDir/trunk/NDHMS/Run/wrf_hydro.exe


###################################
## Clone domainRunDir for
## non-docker applications.
###################################
## TODO JLM: also have to tear this down? optionally?


if [[ ! -d $domainSourceDir ]]; then
    echo "The domain source: $domainSourceDir"
    echo "does not exist. Exiting."
    exit 1
fi
## should the above live elsewhere?

if [[ ! -z $domainRunDir ]]; then
    if [[ -e $domainRunDir ]]; then
        chmod -R 755 $domainRunDir
        rm -rf $domainRunDir
    fi
    if [[ "$domainSourceDir" = /* ]]; then
	cp -as $domainSourceDir $domainRunDir
    else
	cp -as `pwd`/$domainSourceDir $domainRunDir
    fi
    chmod -R 755 $domainRunDir
else
    if [[ $inDocker == "FALSE" ]]; then
	## JLM: this does not catch drives mounted from host into the docker container.
	echoTee "You are not in docker and you have not specified "                           
        echoTee "the \$domainRunDir environment variable. "                                   
        echoTee "Exiting instead of writing into your \$domainSourceDir."                     
	exit 1
    fi
    export domainRunDir=$domainSourceDir
fi


###################################
## Setup github authitcation
###################################

if [[ ! -z ${GITHUB_SSH_PRIV_KEY} ]]; then

    if [ -z `printenv | grep SSH_AGENT_PID` ]; then
        echoTee "Initialising new SSH agent..."                                               
        ssh-agent -k 
        eval "$(ssh-agent -s)" 
        ssh-add $GITHUB_SSH_PRIV_KEY
    fi
    export GIT_PROTOCOL=ssh

else

    if [[ -z ${GITHUB_USERNAME} ]]; then
        echoTee "The required environment variable GITHUB_USERNAME has"                        
        echoTee "not been supplied. Exiting."                                                 
        exit 1
    fi

    if [[ -z ${GITHUB_AUTHTOKEN} ]]; then
        echoTee "The required environment variable GITHUB_AUTHTOKEN has "                     
        echoTee "not been supplied. (A local ssh private key has also not "                   
        echoTee "been supplied). You will be required to authenticate over https."            
        export authInfo=${GITHUB_USERNAME}
        export GIT_PROTOCOL=https
    else 
        export authInfo=${GITHUB_USERNAME}:${GITHUB_AUTHTOKEN}
        export GIT_PROTOCOL=https
    fi
    
fi


if [[ -z $candidateLocalPath ]]; then
    if [[ -z ${candidateFork} ]]; then export candidateFork=${GITHUB_USERNAME}/wrf_hydro_nwm; fi
    if [[ -z ${candidateBranchCommit} ]]; then export candidateBranchCommit=master; fi
fi
if [[ -z $referenceLocalPath ]]; then
    if [[ -z ${referenceFork} ]]; then export referenceFork=NCAR/wrf_hydro_nwm; fi
    if [[ -z ${referenceBranchCommit} ]]; then export referenceBranchCommit=master; fi
fi


###################################
## Modules
###################################
echoTee
echoTee -e "\e[0;49;32m-----------------------------------\e[0m"                              
if [[ ! -z $WRF_HYDRO_MODULES ]]; then
    message="\e[7;49;32mModule information                                           \e[0m"
    echoTee -e "$message"                                                                     
    echoTee "module purge"                                                                    
    module purge
    echoTee "module load $WRF_HYDRO_MODULES"                                                  
    module load $WRF_HYDRO_MODULES
    module list
    ##cannot capture the previous line
else 
    message="\e[7;49;32mConfiguration information:\e[0m"
    echoTee -e "$message"                                                                     
    echoTee                                                                                   
    ## give the fortran+mpi version
    if [[ $HOSTNAME != *tfe* ]]; then
	echoTee "mpif90 --version:"                                                           
	mpif90 --version
    else
	echoTee "mpiifort --version:"                                                         
	mpiifort --version
    fi	
    echoTee
    ## give the netcdf version + other info
    echoTee "nc-config --version --fc --fflags --flibs:"                                      
    nc-config --version --fc --fflags --flibs
fi

###################################
## Check the compiler is what was requested
###################################
if [[ $WRF_HYDRO_COMPILER == intel ]]; then
    export MACROS_FILE=macros.mpp.ifort
    if [[ $HOSTNAME != *tfe* ]]; then
	mpif90 --version | grep -i intel > /dev/null 2>&1 || {
            echoTee 'The requested compiler was not found, exiting.'
            exit 1
	}
    else
	mpiifort --version | grep -i intel > /dev/null 2>&1 || {
            echoTee 'The requested compiler was not found, exiting.'
            exit 1
	}
    fi

fi

if [[ $WRF_HYDRO_COMPILER == GNU ]]; then
    export MACROS_FILE=macros.mpp.gfort
    mpif90 --version | grep -i GNU > /dev/null 2>&1 || {
        echoTee 'The requested compiler was not found, exiting.'
        exit 1
    }
fi 

###################################
## NetCDF env variable setup after modules
###################################
netcdfStr=`echo $NETCDF | cut -d' ' -f1`
if [[ $netcdfStr == *export* ]]; then
    eval $NETCDF
fi

