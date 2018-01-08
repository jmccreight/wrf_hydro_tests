#!/bin/bash
###################################
##q Compile Candidate Binary
##q Question: Does the candidate binary compile?
##q Directory: Either $REPO_DIR/candidate (if code is remote), or
##q            $candidateLocalPath if code is local.
###################################
echo
echo -e "\e[0;49;32m-----------------------------------\e[0m"
echo -e "\e[7;49;32mcompile.sh:\e[0m"
echo -e "\e[0;49;32mQuestion: Does candidate binary compile?\e[0m"    
if [[ -z $candidateLocalPath ]]; then
    cd $candidateRepoDir/trunk/NDHMS/ || \
	{ echo "Unale to cd to $candidateRepoDir/trunk/NDHMS/. Exiting."; exit 1; }
else
    cd $candidateLocalPath/trunk/NDHMS/ || \
	{ echo "Unale to cd to $candidateLocalPath/trunk/NDHMS/. Exiting."; exit 1; }
fi
echo
## JLM TODO: for compiler flexibility the success and failure messages need placed inside the
## following scripts.
$toolboxDir/config_compile_gnu_NoahMP.sh || \
    { echo -e "\e[5;49;31mAnswer: Candidate binary compile failed under GNU.\e[0m"; exit 1; }
echo -e "\e[5;49;32mAnswer: Candidate binary compile successful under GNU!\e[0m"

exit 0
