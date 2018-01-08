###################################
##q Candidate Regression Test
##q Question: Does the Candidate run match a reference run?
##q Directories:
##q    reference compile: Either $REPO_DIR/reference (if code is remote), or
##q                       $referenceLocalPath if code is local.
##q    reference run    : $domainRunDir/run.reference
##q Compares: All restart files RESTART, HYDRO_RST, and nudging (if available). 
###################################

## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mReference fork: compiling.\e[0m"    
if [[ -z $referenceLocalPath ]]; then
    cd $refRepoDir/trunk/NDHMS/
else
    cd $referenceLocalPath/trunk/NDHMS/
fi
echo
$WRF_HYDRO_TESTS_DIR/toolbox/config_compile_gnu_NoahMP.sh || \
    { echo -e "\e[5;49;31mReference fork: compilation under GNU failed.\e[0m"; exit 1; }
echo -e "\e[5;49;32mReference fork: compilation under GNU successful!\e[0m"

###################################
## Run Reference Binary
###################################
## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mReference binary: running (with $nCoresDefault cores).\e[0m"
cd $domainRunDir/run.reference
cp $referenceBinary .
mpirun -np $nCoresDefault ./`basename $referenceBinary` 1> `date +'%Y-%m-%d_%H-%M-%S.stdout'` 2> `date +'%Y-%m-%d_%H-%M-%S.stderr'` 
## did the model finish successfully?
## This grep is >>>> FRAGILE <<<<. But fortran return codes are un reliable. 
nSuccess=`grep 'The model finished successfully.......' diag_hydro.* | wc -l`
if [[ $nSuccess -ne $nCoresDefault ]]; then
    echo -e "\e[5;49;31mReference binary: run failed.\e[0m"
    exit 2
fi
echo -e "\e[5;49;32mReference binary: run successful!\e[0m"

###################################
## Regression of candidate on reference
###################################
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mTest: Regression test.\e[0m"

#compare restart files
python3 $answerKeyDir/compare_restarts.py $domainRunDir/run.candidate $domainRunDir/run.reference || \
    { echo -e "\e[5;49;31mRegression test: restart comparison failed.\e[0m"; exit 1; }
echo -e "\e[5;49;32mRegression test: restart comparison successful!\e[0m"

