#!/bin/bash
# Script to append individual netcdf files together into a single file using ncks
# Usage: ./ncks_file_concatenator.sh
# Usage: ./ncks_file_concatenator.sh -k  ## keeps input files
# Output: A single WRF-Hydro input file called 'Fulldom_hires_netcdf_file.nc' that contains all the individual high-res
# netcdf file layers.
#
# Notes: This script is frequently used to concatenate the individual netcdf file layers that are generated for use as
# the 'routing grids' in WRF-Hydro.  You will first need to 'unzip' the zipfile that is created from either the stand-alone
# routing grid tool or the one downloaded from the ArcGIS WRF-Hydro pre-processing web service first to create the individual
# file layers that will be concatenated. This script also erases those individual layers when finishing so be sure to keep
# your original zip file.
# Optionally, files are not erased with the -k flag
# Developed: 12/1/2012, D. Gochis
# Tweaks:     9/2/2015, J. McCreight

### EDIT THESE FILENAMES AS NEEDED....
outfile="Fulldom_hires_netcdf_file.nc"
file1="topography.nc"
file2="flowdirection.nc"
file3="CHANNELGRID.nc"
file4="str_order.nc"
file5="gw_basns.nc"
file6="retdeprtfac.nc"
file7="ovroughrtfac.nc"
file8="LAKEGRID.nc"
file9="frxst_pts.nc"
file10="latitude.nc"
file11="longitude.nc"
file12="LINKID.nc"

### NO EDITS NECESSARY BELOW HERE ####
echo $file1
ncks $file1 $outfile
echo $file2
ncks -A $file2 $outfile
echo $file3
ncks -A $file3 $outfile
echo $file4
ncks -A $file4 $outfile
echo $file5
ncks -A $file5 $outfile
echo $file6
ncks -A $file6 $outfile
echo $file7
ncks -A $file7 $outfile
echo $file8
ncks -A $file8 $outfile
echo $file9
ncks -A $file9 $outfile
echo $file10
ncks -A $file10 $outfile
echo $file11
ncks -A $file11 $outfile
if [ -e "$file12" ]
then
    echo $file12
    ncks -A $file12 $outfile
fi

if [ "$1" == "-k" ] 
then
    exit 0
fi

rm $file1 $file2 $file3 $file4 $file5 $file6 $file7 $file8 $file9 $file10 $file11 $file12

exit 0
