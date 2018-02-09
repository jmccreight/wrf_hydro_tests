#!/bin/bash

## Purpose:
## 1) A mpif90 configure not dependent on arbitrary numbers in the configure script.
## 2) Use envrionment variables to determine compile-time options.
## 3) Report the choice of environment variables.

## Run this in the wrf_hydro_nwm/trunk/NDHMS directory.
## TODO JLM: enforce that basename is NDHMS?

#############################################
## Configure
#############################################
if [[ $WRF_HYDRO_COMPILER == GNU ]];   then ./configure gfort;  fi
if [[ $WRF_HYDRO_COMPILER == intel ]]; then ./configure ifort;  fi

#############################################
## Compile
#############################################
## This is taken from
## wrf_hydro_tools/utilities/use_env_compileTag_offline_NoahMP.sh
## but made to be stand-alone.
## This will need updated from time-to-time.

function henv { 
    grepStr="(WRF_HYDRO)|(HYDRO_D)|(SPATIAL_SOIL)|(WRF_HYDRO_RAPID)|(WRFIO_NCD_LARGE_FILE_SUPPORT)|(HYDRO_REALTIME)|(NCEP_WCOSS)|(WRF_HYDRO_NUDGING)|(NETCDF)"
    printenv | egrep -w "${grepStr}" | sort
}
echo '*****************************************************************'
echo "The envrionment variables use in the compile (alphabetically):"
henv
echo '*****************************************************************'
echo

if [[ "$WRF_HYDRO" -ne 1 ]]; then
    echo "Please set WRF_HYDRO to be 1"
    exit
fi

rm -f  LandModel LandModel_cpl
cp arc/Makefile.NoahMP Makefile
cd Land_models/NoahMP
cp hydro/Makefile.hydro Makefile
if [[ -e "MPP" ]]; then  rm -rf  MPP; fi
ln -sf ../../MPP .
cd ../..

ln -sf Land_models/NoahMP LandModel
cat macros LandModel/hydro/user_build_options.bak  > LandModel/user_build_options
ln -sf CPL/NoahMP_cpl LandModel_cpl
make clean 2>/dev/null 1>/dev/null
rm -f Run/wrf_hydro_NoahMP.exe 

echo "Compiling, showing only standard error..."
make 1>/dev/null

if [[ $? -eq 0 ]]; then
    echo
    echo '*****************************************************************'
    echo
    echo "Make was successful"
else 
    echo
    echo '*****************************************************************'
    echo
    echo "Make NOT successful"
    exit 1
fi
echo

exit 0
