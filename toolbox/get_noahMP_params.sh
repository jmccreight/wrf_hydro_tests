cp $paramsRepoDir/trunk/NDHMS/Run/*TBL . || {
    echo -e "$paramsCanRef parameter tables not found in Run/";
    echo -e "Attempting to find in template/HYDRO and Land_models/NoahMP/run";
    cp $paramsRepoDir/trunk/NDHMS/template/HYDRO/*TBL . || {
        echo -e "$paramsCanRef parameter tables not found in template/HYDRO";
        exit 1; } ;
    cp $paramsRepoDir/trunk/NDHMS/Land_models/NoahMP/run/*TBL . || {
        echo -e "$paramsCanRef parameter tables not found in Land_models/NoahMP/run";
        exit 1;} ;
    echo ;
}

