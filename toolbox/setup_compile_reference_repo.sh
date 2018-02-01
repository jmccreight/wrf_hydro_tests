###################################
## Clone reference fork into repos directory
###################################
## The reference fork can be optional if both $referenceLocalPath and $referenceFork equal ''.
if [[ -z $referenceLocalPath ]]; then
    if [[ ! -z $referenceFork ]]; then
	if [[ -e $refRepoDir ]]; then
            chmod -R 755 $refRepoDir
            rm -rf $refRepoDir
	fi
	mkdir -p $refRepoDir
	cd $refRepoDir
	echo -e "\e[0;49;32m-----------------------------------\e[0m"
	echo -e "\e[7;49;32mReference fork: $referenceFork\e[0m"
	echo -e "\e[7;49;32mReference branch/commit: $referenceBranchCommit\e[0m"
	git clone https://${authInfo}@github.com/$referenceFork $refRepoDir    
	git checkout $referenceBranchCommit || \
            { echo "Unsuccessful checkout of $referenceBranchCommit from $referenceFork."; exit 1; }
	echo -e "\e[0;49;32mRepo in\e[0m `pwd`"
	echo -e "\e[0;49;32mReference branch:\e[0m    `git rev-parse --abbrev-ref HEAD`"
	echo -e "\e[0;49;32mReference commit:\e[0m"
	git log -n1 | cat
    fi
else
    cd $referenceLocalPath
    echo
    echo -e "\e[0;49;32m-----------------------------------\e[0m"
    echo -e "\e[7;49;32mReference fork: LOCAL: `pwd` \e[0m"
    echo -e "\e[0;49;32mReference branch:\e[0m    `git rev-parse --abbrev-ref HEAD`"
    gitDiffInd=`git diff-index HEAD -- `
    if [[ -z $gitDiffInd ]]; then 
        echo -e "\e[0;49;32mTesting commit:\e[0m"
        git log -n1 | cat
    else 
        echo  -e "\e[0;49;32mTesting uncommitted changes.\e[0m"
    fi
    cd - >/dev/null 2>&1
fi


###################################
## Compile
###################################
## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32m${questionFileName}:\e[0m"
echo -e "\e[0;49;32mCompiling reference binary.\e[0m"
## This should, in theory, never fail. Though could be possible is unexpected/untested
## compile options are passed to the reference build.
if [[ -z $referenceLocalPath ]]; then
    cd $refRepoDir/trunk/NDHMS/
    theCompDir=$refRepoDir/trunk/NDHMS/
else
    cd $referenceLocalPath/trunk/NDHMS/
    theCompDir=$referenceLocalPath/trunk/NDHMS/
fi
echo "Compiling in $theCompDir"
echo
$toolboxDir/config_compile_NoahMP.sh || \
    { echo -e "\e[5;49;31mReference binary: compilation under $WRF_HYDRO_COMPILER failed unexpectedly.\e[0m"; 
      echo "See results in $theCompDir"; 
      exit 1; }
echo -e "\e[0;49;32mReference binary: compilation under $WRF_HYDRO_COMPILER successful.\e[0m"
