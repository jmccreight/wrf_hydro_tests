#!/bin/bash
## Below requires environment variables set in config.sh
## Source this script.
## After informative message: exit on failure with non-zero status.
## Do not exit otherwise.

#Specify link to binaries after compilation
theBinary=$testRepoDir/trunk/NDHMS/Run/wrf_hydro.exe
theRefBinary=$refRepoDir/trunk/NDHMS/Run/wrf_hydro.exe

#Specify number of cores
nCoresFull=2
nCoresTest=1

###################################
## COMPILE test repo
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'compile' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: compiling.\e[0m"
    
    cd $testRepoDir/trunk/NDHMS/
    echo

    #cp /root/wrf_hydro_tools/utilities/use_env_compileTag_offline_NoahMP.sh .
    ## 2 is gfort  >>>> FRAGILE <<<<
    #./use_env_compileTag_offline_NoahMP.sh 2 || { echo "Compilation failed."; exit 1; }    
    #Set environment variables. This will likely need to be hard coded so that people don't change compile time options
    ./setEnvar.sh
    ./configure 2
    echo Compiling, showing only standard error.
    ./compile_offline_NoahMP.sh 1>/dev/null || \
	{ echo -e "\e[5;49;31mTest fork: compilation failed under GNU.\e[0m"; exit 1; }
    echo -e "\e[5;49;32mTest fork: successful compilation under GNU!\e[0m"
fi

###################################
## run test repo
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'run' ]]; then
    ###################################
    ## Test Run = run 1
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: running (with $nCoresFull cores).\e[0m"
    cd $domainSourceDir/run.1.new
    cp $theBinary .
    mpirun -np $nCoresFull ./`basename $theBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
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
## Reference Run = run 2:
## THis requires compiling the old binary, which in theory is not an issue. 
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'compile' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mReference fork: compiling.\e[0m"
    
    cd $refRepoDir/trunk/NDHMS/
    echo
    #cp /root/wrf_hydro_tools/utilities/use_env_compileTag_offline_NoahMP.sh .
    
    ## 2 is gfort  >>>> FRAGILE <<<<
    #./use_env_compileTag_offline_NoahMP.sh 2 || { echo "Compilation failed."; exit 3; }
    
    #Set environment variables. This will likely need to be hard coded so that people don't change compile time options
    ./setEnvar.sh
    ./configure 2
    echo Compiling, showing only standard error.
    ./compile_offline_NoahMP.sh 1>/dev/null || \
	{ echo -e "\e[5;49;31mReference fork: compilation under GNU failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32mReference fork: compilation under GNU successful!\e[0m"
fi

###################################
## run reference repo & perform regression test
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'run' ]]; then
	echo
	echo -e "\e[0;49;32m-----------------------------------\e[0m"
	echo -e "\e[7;49;32mReference fork: running (with $nCoresFull cores).\e[0m"
	cd $domainSourceDir/run.2.old
	cp $theRefBinary .
	mpirun -np $nCoresFull ./`basename $theRefBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 

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
	python3 $answerKeyDir/compare_restarts.py $domainSourceDir/run.1.new $domainSourceDir/run.2.old || \
            { echo -e "\e[5;49;31mRegression test: restart comparison failed.\e[0m"; exit 1; }
	echo -e "\e[5;49;32mRegression test: restart comparison successful!\e[0m"
fi

###################################
## Run 3: perfect restarts
###################################
## run restart tests
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'restart' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest fork: running from restart\e[0m"
    cd $domainSourceDir/run.3.restart_new
    cp $theBinary .
    mpirun -np $nCoresFull ./`basename $theBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    
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
    python3 $answerKeyDir/compare_restarts.py $domainSourceDir/run.1.new $domainSourceDir/run.3.restart_new \
	|| { echo -e "\e[5;49;31mPerfect restart test: restart comparison failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32mPerfect restart test: restart comparison successful!\e[0m"
fi

###################################
## Run 4: ncores test
if [[ "${1}" == 'all' ]] || [[ "${1}" == 'ncores' ]]; then
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mRunning test fork with $nCoresTest cores\e[0m"
    
    cd $domainSourceDir/run.4.ncores_new
    cp $theBinary .
    echo mpirun -np $nCoresTest ./`basename $theBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    mpirun -np $nCoresTest ./`basename $theBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
    
    cd ../
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mTest: # cores test\e[0m"
    
    #compare restart files
    python3 $answerKeyDir/compare_restarts.py $domainSourceDir/run.1.new $domainSourceDir/run.4.ncores_new \
	|| { echo -e "\e[5;49;31m# cores test: restarts comparison failed.\e[0m"; exit 1; }
    echo -e "\e[5;49;32m# cores test: restart comparison successful!\e[0m"    
fi
