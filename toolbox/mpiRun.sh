
function mpiRunFunc 
{ 
    local nCores=$1; 
    local theBinary=$2;
    dateTag=`date +'%Y-%m-%d_%H-%M-%S'`
    runCmd="mpirun -np $nCores ./`basename $theBinary` 1> ${dateTag}.stdout 2> ${dateTag}.stderr";
    echo $runCmd
    eval $runCmd 
    return $?
}
## This one covers docker. Works on cheyenne too, for small numbers of cores... for now.

export -f mpiRunFunc
export WRF_HYDRO_RUN=mpiRunFunc
