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

