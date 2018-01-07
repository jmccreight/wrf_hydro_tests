#!/bin/bash

## Purpose:
## 1) A gnu mpif90 configure not dependent on arbitrary numbers in the configure script.
## 2) Use envrionment variables to determine compile-time options.
## 3) Report the choice of environment variables.

## Run this in the wrf_hydro_nwm/trunk/NDHMS directory.
## TODO JLM: enforce that basename is NDHMS?

## TODO JLM: check that gnu is present?
## e.g. mpif90 --version | grep -i intel > /dev/null 2>&1 || echo PROBLEM

#############################################
## Construct our own gnu-mpi90 macros file
#############################################
## TODO: how platform independent is this? should be fine. but check.

echo "NETCDF_INC = ${NETCDF}/include" > macros.tmp
echo "NETCDF_LIB = ${NETCDF}/lib" >> macros.tmp
echo "NETCDFLIB  = -L\$(NETCDF_LIB) -lnetcdff -lnetcdf" >> macros.tmp

if [[ -e macros ]]; then rm -f macros; fi
cp arc/macros.mpp.gfort macros 
cp arc/Makefile.mpp Makefile.comm

if [[ ! -e lib ]]; then mkdir lib; fi
if [[ ! -e mod ]]; then mkdir mod; fi

if [[ -e macros.tmp ]]; then
    cat macros macros.tmp > macros.a
    rm -f macros.tmp; mv macros.a macros
fi

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
    echo "Please set WRF_HYDRO to be 1 from setEnvar.sh"
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
    echo "Make was successful"
else 
    echo
    echo '*****************************************************************'
    echo
    echo "Make NOT successful"
    exit 1
fi

echo '*****************************************************************'
echo "The envrionment variables use in the compile (alphabetically) AGAIN:"
henv
echo '*****************************************************************'
echo 

exit 0
