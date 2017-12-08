#!/bin/bash

tmpPath=`grep "tmpPath" $toolboxDir/ncoScripts | cut -d '=' -f2 | tr -d ' '` 

# These derived from examples found here: http://nco.sourceforge.net/nco.html#filters

# ncattget $att_nm $var_nm $fl_nm : What attributes does variable have?
function ncattget { ncks -M -m ${3} | grep -E -i "^${2} attribute [0-9]+: ${1}" | cut -f 11- -d ' ' | sort ; }

# ncunits $att_val $fl_nm : Which variables have given units?
function ncunits { ncks -M -m ${2} | grep -E -i " attribute [0-9]+: units.+ ${1}" | cut -f 1 -d ' ' | sort ; }

# ncavg $var_nm $fl_nm : What is mean of variable?
function ncavg { ncwa -y avg -O -C -v ${1} ${2} ~/foo.nc ; ncks -H -C -v ${1} ~/foo.nc | cut -f 3- -d ' ' ; }

# ncavg $var_nm $fl_nm : What is mean of variable?
function ncavg { ncap2 -O -C -v -s "foo=${1}.avg();print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }

# ncdmnsz $dmn_nm $fl_nm : What is dimension size?
function ncdmnsz { ncks -m -M ${2} | grep -E -i ": ${1}, size =" | cut -f 7 -d ' ' | uniq ; }

# ncVarlist $fl_nm : What variables are in file?
function ncVarList { ncks -m ${1} | grep -E ': type' | cut -f 1 -d ' ' | sed 's/://' | sort ; }

# mvVarType
function ncVarType { 
    functionId funcId
    if [ -z "$2" ] ## only one arg in
    then
	for var in `ncVarList ${1}`
	do 
	    ncVarType $var ${1}
	done 
    else
	local dumFile=/${tmpPath}/ncDum${USER}${funcId}.nc
	type=`ncap2 -O -C -v -s "foo=${1}.type();print(foo)" ${2} $dumFile | cut -f 3- -d ' '`
	\rm -f $dumFile
	echo ${1} : Type=$type
    fi
}


# ncVarMax $var_nm $fl_nm : What is maximum of variable?
# if only 1 variable (filename) then print the info for all variables in the file.
# if varname is specified, then print for only that variable
function ncVarMax { 
    functionId funcId
    local dumFile=/${tmpPath}/ncDum${USER}${funcId}.nc
    if [ -z "$2" ] ## only one arg in
    then
	for var in `ncVarList ${1}`
	do 
	    ncVarMax $var ${1}
	done 
    else
	max=`ncap2 -O -C -v -s "foo=${1}.max();print(foo)" ${2} $dumFile | cut -f 3- -d ' '`
	\rm -f $dumFile
	echo ${1} : Max=$max
    fi
}


function ncVarNa {
    functionId funcId
    local dumFile=/${tmpPath}/ncDum${USER}${funcId}.nc
    ## It appears that if there are nans, having _FillValue set to NaN does
    ## NOT mask them from the ncap sum I'm using to test. So can skip applying
    ## the next two lines in anyway.
    #ncatted -a _FillValue,,o,f,NaN $dumFile
    #ncatted -a _FillValue,,m,f,1.0e36 $dumFile
    if [ -z "$2" ] ## only one arg in
    then
        retVal=0
	for var in `ncVarList ${1}`
	do 
	    ncVarNa $var ${1}
            retVal=$(($retVal + $?))
	done 
        return $retVal
    else
        ## as noted, this seems to work regardless of _FillValue=NaN
        sum=`ncap2 -O -C -v -s "sum=(${1}*0.0).total();print(sum)" ${2} $dumFile | cut -f 2 -d '=' | tr -d ' ' | grep -i '0'`
        if [ -z $sum ]
        then
	    echo -e "$1 : \e[31mNaNs present\e[0m"   
            return 1
        fi 
        return 0
    fi
}


function ncVarFill {
    functionId funcId
    local dumFile=/${tmpPath}/ncDum${USER}${funcId}.nc
## notes from ncVarNa
    ## It appears that if there are nans, having _FillValue set to NaN does
    ## NOT mask them from the ncap sum I'm using to test. So can skip applying
    ## the next two lines in anyway.
    #ncatted -a _FillValue,,o,f,NaN $dumFile
    #ncatted -a _FillValue,,m,f,1.0e36 $dumFile
    if [ -z "$2" ] ## only one arg in
    then
        retVal=0
	for var in `ncVarList ${1}`
	do 
	    ncVarFill $var ${1}
            retVal=$(($retVal + $?))
	done 
        return $retVal
    else
        nMiss=`ncap2 -O -C -v -s "nMiss=${1}.number_miss();print(nMiss)" ${2} $dumFile | cut -f 2 -d '=' | tr -d ' '`
        if [ $nMiss -ne 0 ]
        then
            fillVal=`ncap2 -O -C -v -s "fillVal=${1}.get_miss();print(fillVal)" ${2} $dumFile`  
	    echo -e "$1 : \e[31m$nMiss fill values present ( $fillVal )\e[0m"   
            return 1
        fi 
        return 0
    fi
}

# ncmdn $var_nm $fl_nm : What is median of variable?
function ncmdn { ncap2 -O -C -v -s "foo=gsl_stats_median_from_sorted_data(${1}.sort());print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }


# ncrng $var_nm $fl_nm : What is range of variable?
function ncVarRng { 
    functionId funcId
    local dumFile=/${tmpPath}/ncDum${USER}${funcId}.nc
    if [ -z "$2" ] ## only one arg in
    then
	for var in `ncVarList ${1}`
	do 
	    ncVarRng $var ${1}
	done 
    else


	type=`ncVarType $1 $2 | cut -f 2- -d '='`
        ##echo $type
        #echo $dumFile

        if [[ ! $type -eq 2 && ! $type -eq 4 && ! $type -eq 5 && ! $type -eq 6 ]]; then
            echo "Variable type not yet covered: " $1
            return 1
        fi

	if [[ $type -eq 4 ]]  ## integer
	then 
	    rng=`ncap2 -O -C -v -s "foo_min=${1}.min();foo_max=${1}.max();print(foo_min,\"( %i\");print(\" , \");print(foo_max,\"%i )\")" ${2} $dumFile`
        fi

	if [[ $type -eq 5 || $type -eq 6 ]]  ## real
        then
	    rng=`ncap2 -O -C -v -s "foo_min=${1}.min();foo_max=${1}.max();print(foo_min,\"( %f\");print(\" , \");print(foo_max,\"%f )\")" ${2} $dumFile`
	fi 

	if [[ $type -eq 2 ]]  ## character
        then
            echo -e "\e[31m$1: not currently providing ranges for character type\e[0m"
	    #rng=`ncap2 -O -C -v -s "foo_min=${1}.min();foo_max=${1}.max();print(foo_min,\"( %s\");print(\" , \");print(foo_max,\"%s )\")" ${2} $dumFile`
	fi 

        ## want to identify if ncVarDiff called ncVarRng
        myFuncName=`echo ${FUNCNAME[*]}`
        thisFunc=`echo $funcId | cut -d'.' -f2`
        matchLine=`echo "$myFuncName" | tr ' ' '\n' | grep -n $thisFunc | cut -d':' -f1 | tail -1`
        ## this already adds 1 because array is zero indexed
        callFunc=${FUNCNAME[$matchLine]}  ##modify the identitier based on calling routine name
	if [[ $zeroDiffs -eq 0 ]] && [[ $callFunc == 'ncVarDiff' ]]
	then 
	    nonZeros=`echo $rng | sed 's/[^1-9]//g'`
	    if [ -e $nonZeros ]; then 
		\rm -f $dumFile
                return 0
	    fi
	fi

	outputId='Range' ## basic identifier
        if [[ $callFunc == 'ncVarDiff' ]]; then outputId="DIFF $outputId"; fi 
	echo ${1} : $outputId=$rng
	\rm -f $dumFile
        retVal=1
    fi
    return $retVal
}

## var or no var specified. 
## ncVarDiff [var] file1 file2
## var can be a comma separated list of variables!
## e.g.
##jamesmcc@hydro-c1:~/DART/lanai/models/wrfHydro/work> ncVarDiff LAI,WT,WOOD RESTART.2013091200_DOMAIN3.orig restart.nc 
function ncVarDiff {
    OPTIND=1
    local zeroDiffs=0
    while getopts ":z" opt; do
	case $opt in
	    z) zeroDiffs=1
	       ;;
	    \?)
		echo "Invalid option: -$OPTARG" >&2
		;;
	esac
    done   
    shift $((OPTIND-1))
    [ "$1" = "--" ] && shift

    functionId funcId
    local dumFile=/${tmpPath}/ncDum${USER}${funcId}.nc
    if [ -z "$3" ] ## only two args in
    then
	if ! ncCheckExist $1 $2; then return 1; fi
	ncdiff ${1} ${2} $dumFile
    else 
	if ! ncCheckExist $2 $3; then return 1; fi
	ncdiff -v ${1} ${2} ${3} $dumFile
    fi 
    ncVarRng $dumFile
    retNcVarRng=$?
    \rm -f $dumFile
    return $retNcVarRng
}


# ncmode $var_nm $fl_nm : What is mode of variable?
function ncmode { ncap2 -O -C -v -s "foo=gsl_stats_median_from_sorted_data(${1}.sort());print(foo)" ${2} ~/foo.nc | cut -f 3- -d ' ' ; }

# ncrecsz $fl_nm : What is record dimension size?
function ncrecsz { ncks -M ${1} | grep -E -i "^Record dimension:" | cut -f 8- -d ' ' ; }

## get a function id for managin file creation/removal
function functionId {
    eval "$1=${BASHPID}.${FUNCNAME[1]}"
}
    
## check file eixistence b/c resulting error messages can be extremely confusing.
function ncCheckExist {
    for file in "$@"
    do
	if [ ! -e $file ]
	then
	    echo "File does NOT exist: $file"
	    return 1
	fi 
    done
    return 0
}


# Check if a value exists in an array
# @param $1 element
# @param $2 array
# @return  Success (0) if value exists, Failure (1) otherwise
# Usage: in_array "$needle" "${haystack[@]}"
# See: http://fvue.nl/wiki/Bash:_Check_if_array_element_exists
#function whichArr {
#    value="$1"
#    array="$2"
#    local i=1;
#    for member in "${array[@]}"; do
#        echo "member: $member"
#        if [[ "$member" == "$value" ]]; then
#            echo $i
#        fi
#        ((i++))
#    done
#    return 0
#}

#function whichArr {
#    local  value="$1"
#    array=("${2}")
#echo "fooo: $value"
#echo "bar: ${array[@]}"
#    for (( i=0;i < ${#array[@]}; i++)); do
#        x="${array[$i]}"
#        [ "$value" == "$x" ] && echo $i
#    done
#    return 1
#}

#function whichArrLast {
#    element=$1
#    array=$2
#    wh=`whichArr "$element" "$member"`
#    echo `echo $wh | tr ' ' '\n' | tail -1`
#    return 0
#}
