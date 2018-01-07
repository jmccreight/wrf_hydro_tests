#!/bin/bash
## Below requires environment variables set in config.sh
## Source this script.
## After informative message: exit on failure with non-zero status.
## Do not exit otherwise.

#Specify link to binaries after compilation
testBinary=$testRepoDir/trunk/NDHMS/Run/wrf_hydro.exe
refBinary=$refRepoDir/trunk/NDHMS/Run/wrf_hydro.exe

#Specify number of cores
nCoresFull=2
nCoresTest=1

###################################
## Test Repo Compile
###################################
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'compile' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: compiling.\e[0m"    
    if [[ -z $testLocalPath ]]; then
        cd $testRepoDir/trunk/NDHMS/
    else
        cd $testLocalPath/trunk/NDHMS/
    fi
    pwd
    echo
    $WRF_HYDRO_TESTS_DIR/toolbox/config_compile_gnu_NoahMP.sh || \
        { echo -e "\e[5;49;31mTest fork: compilation failed under GNU.\e[0m"; exit 1; }
    echo -e "\e[5;49;32mTest fork: successful compilation under GNU!\e[0m"
fi

###################################
## Reference Repo Compile
###################################
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'compile' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mReference fork: compiling.\e[0m"    
    if [[ -z $testLocalPath ]]; then
        cd $refRepoDir/trunk/NDHMS/
    else
        cd $referenceLocalPath/trunk/NDHMS/
    fi
    echo
    $WRF_HYDRO_TESTS_DIR/toolbox/config_compile_gnu_NoahMP.sh || \
	{ echo -e "\e[5;49;31mReference fork: compilation under GNU failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32mReference fork: compilation under GNU successful!\e[0m"
fi

###################################
## Test Repo Run
###################################
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'run' ]]; then
    ###################################
    ## Test Run = run 1
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: running (with $nCoresFull cores).\e[0m"
    cd $domainTestDir/run.1.new
    cp $testBinary .
    mpirun -np $nCoresFull ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    ## did the model finish successfully?
    ## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
    nSuccess=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
    if [[ $nSuccess -ne $nCoresFull ]]; then
	echo -e "\e[5;49;31mTest fork run: failed.\e[0m"
	exit 2
    fi
    echo -e "\e[5;49;32mTest fork: run successful!\e[0m"

fi

###################################
## Reference Repo Run + Regression test
###################################
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'run' ]]; then
	echo
	echo -e "\e[0;49;32m-----------------------------------\e[0m"
	echo -e "\e[7;49;32mReference fork: running (with $nCoresFull cores).\e[0m"
	cd $domainTestDir/run.2.old
	cp $refBinary .
	mpirun -np $nCoresFull ./`basename $refBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 

	## did the model finish successfully?
	## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
	nSuccess=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
	if [[ $nSuccess -ne $nCoresFull ]]; then
	    echo -e "\e[5;49;31mReference fork: run failed.\e[0m"
	    exit 4
	fi
	echo -e "\e[5;49;32mReference fork: run successful!\e[0m"
	
	echo
	echo -e "\e[0;49;32m-----------------------------------\e[0m"
	echo -e "\e[7;49;32mTest: Regression test.\e[0m"

	#compare restart files
	python3 $answerKeyDir/compare_restarts.py $domainTestDir/run.1.new $domainTestDir/run.2.old || \
            { echo -e "\e[5;49;31mRegression test: restart comparison failed.\e[0m"; exit 1; }
	echo -e "\e[5;49;32mRegression test: restart comparison successful!\e[0m"
fi

###################################
## Test Repo: Perfect Restarts
###################################
## run restart tests
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'restart' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: running from restart\e[0m"
    cd $domainTestDir/run.3.restart_new
    cp $testBinary .
    mpirun -np $nCoresFull ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    
    ## did the model finish successfully?
    ## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
    nSuccess=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
    if [[ $nSuccess -ne $nCoresFull ]]; then
	echo Run run.1.new failed.
	exit 2
    fi
    
    cd ../
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest: Perfect restart test.\e[0m"
    
    #compare restart files
    python3 $answerKeyDir/compare_restarts.py $domainTestDir/run.3.restart_new $domainTestDir/run.1.new \
	|| { echo -e "\e[5;49;31mPerfect restart test: restart comparison failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32mPerfect restart test: restart comparison successful!\e[0m"
fi

###################################
## Test Repo: # cores test
###################################
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'ncores' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mRunning test fork with $nCoresTest cores\e[0m"
    
    cd $domainTestDir/run.4.ncores_new
    cp $testBinary .
    echo mpirun -np $nCoresTest ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    mpirun -np $nCoresTest ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    
    cd ../
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest: # cores test\e[0m"
    
    #compare restart files
    python3 $answerKeyDir/compare_restarts.py $domainTestDir/run.1.new $domainTestDir/run.4.ncores_new \
	|| { echo -e "\e[5;49;31m# cores test: restarts comparison failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32m# cores test: restart comparison successful!\e[0m"    
fi

###################################
## Test Repo: channel-only test against full model
###################################
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'channel-only_v_full' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mRunning test fork with $nCoresFull in channel-only mode\e[0m"
    
    cd $domainTestDir/run.5.channel-only_new
    cp $testBinary .
    echo mpirun -np $nCoresFull ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    mpirun -np $nCoresFull ./`basename $testBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    
    cd ../
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest: # cores test\e[0m"
    
    #compare restart files
    python3 $answerKeyDir/compare_restarts.py $domainTestDir/run.1.new $domainTestDir/run.4.ncores_new \
	|| { echo -e "\e[5;49;31m# cores test: restarts comparison failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32m# cores test: restart comparison successful!\e[0m"    
fi

