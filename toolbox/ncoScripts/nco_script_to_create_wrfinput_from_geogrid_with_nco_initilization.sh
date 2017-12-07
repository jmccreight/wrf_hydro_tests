#!/bin/sh
# Script to create 'wrfinput' file which contains necessary parameter fields extracted from geogrid file...
# NOTES:
#  VIP!!!!:  - This script only works on geogrid files created from GEOGRID V3.3.0  or later!!!
#            - Geogrid files from earlier versions will need some more modification to create the dominant 
#              soil category fields from its 3-d arrays (SOILCTOP)... 
#            - Script will still run but won't create soil category (ISLTYP) field in new wrfinput file...
#
# Usage: ./nco_script_to_create_wrfinput_from_geogrid.sh
# Developed: 12/22/2012, D. Gochis
# Updated: 03/21/2013 B. Fersch
# Updated: 09/18/2015 L. Karsten Added SEAICE and SNOWH necessary for model run 

#Specify names of input geogrid and output wrfinput files...

# process command line args
if [ $# -lt 3 ]; then 
  echo 
  echo "Missing arguments:"
  echo "\n\nUsage:\n>nco_script_to_create_wrfinput_from_geogrid_with_ncl_initilization.sh [input file] [output file] [simulation start month]"
  echo
  echo "e.g."
  echo " > nco_script_to_create_wrfinput_from_geogrid_with_ncl_initilization.sh geo_em.d01.nc wrfinput_d01.nc 08\n\n"
  exit 2
fi

infile=$1              #"geo_em.d01.nc.4mile_100m.nc"
outfile=$2             #"wrfinput_d01"
vegfrac_init_month=$3



#Extract and rename fields from geogrid to wrfinput...(No edits required here)
ncks -v HGT_M $infile $outfile
ncks -A -v XLAT_M $infile $outfile
ncks -A -v XLONG_M $infile $outfile
ncks -A -v SOILTEMP $infile $outfile
ncks -A -v SCT_DOM $infile $outfile
ncks -A -v LU_INDEX $infile $outfile
ncrename -v HGT_M,HGT $outfile
ncrename -v XLAT_M,XLAT $outfile
ncrename -v XLONG_M,XLONG $outfile
ncrename -v SOILTEMP,TMN $outfile
ncrename -v SCT_DOM,ISLTYP $outfile
ncrename -v LU_INDEX,IVGTYP $outfile


#get VEGFRA in wrfinput...(No edits required here)
ncks -d month,$vegfrac_init_month,$vegfrac_init_month $infile greenfrac.nc 
ncks -v GREENFRAC greenfrac.nc vegfra.nc
ncrename -v GREENFRAC,VEGFRA vegfra.nc
ncap2 -s 'where(VEGFRA!=0.0) VEGFRA=VEGFRA*100.0' vegfra.nc vegfra2.nc
ncks -A -v VEGFRA vegfra2.nc $outfile
rm vegf*.nc greenfrac.nc
echo 'Model setup data completed...your output file is: ' $outfile


# assign values for soil temp, soil moisture, soil water and skin temp initial conditions into wrfinput file
# values can be adjusted for 4 soil layers
cat > ./wrfinput_ncap.nco << EOF 
defdim ("soil_layers_stag",4);
SMOIS[Time,soil_layers_stag, south_north, west_east]=float(0.20);
SMOIS(0,1,,)=float(0.21); 
SMOIS(0,2,,)=float(0.25); 
SMOIS(0,3,,)=float(0.27); 
SH2O[Time, soil_layers_stag, south_north, west_east]=float(0.20);
SH2O(0,1,,)=float(0.21);
SH2O(0,2,,)=float(0.25);
SH2O(0,3,,)=float(0.28);
TSLB[Time, soil_layers_stag, south_north, west_east]=float(285.0);
TSLB(0,1,,)=float(283.0);
TSLB(0,1,,)=float(279.0);
TSLB(0,1,,)=float(277.0);
TSK[Time, south_north, west_east]=float(290.0);
SEAICE[Time, south_north, west_east]=float(0.0);
SNOWH[Time, south_north, west_east]=float(0.0);
EOF

ncap2 -O -h -S wrfinput_ncap.nco $outfile $outfile 
rm wrfinput_ncap.nco

ncatted -a FieldType,SMOIS,c,i,104 \
        -a stagger,SMOIS,c,c,"Z" \
        -a MemoryOrder,SMOIS,c,c,"XYZ" \
        -a description,SMOIS,c,c,"SOIL MOISTURE" \
        -a units,SMOIS,c,c,"m3 m-3" \
        -a coordinates,SMOIS,c,c,"XLONG XLAT" \
        -a FieldType,SH2O,c,i,104 \
        -a stagger,SH2O,c,c,"Z" \
        -a MemoryOrder,SH2O,c,c,"XYZ" \
        -a description,SH2O,c,c,"SOIL LIQUID WATER" \
        -a units,SH2O,c,c,"m3 m-3" \
        -a coordinates,SH2O,c,c,"XLONG XLAT" \
        -a FieldType,TSLB,c,i,104 \
        -a stagger,TSLB,c,c,"Z" \
        -a MemoryOrder,TSLB,c,c,"XYZ" \
        -a description,TSLB,c,c,"SOIL TEMPERATURE" \
        -a units,TSLB,c,c,"K" \
        -a coordinates,TSLB,c,c,"XLONG XLAT" \
        -a FieldType,TSK,c,i,104 \
        -a stagger,TSK,c,c," " \
        -a MemoryOrder,TSK,c,c,"XYZ" \
        -a description,TSK,c,c,"SURFACE SKIN TEMPERATURE" \
        -a units,TSK,c,c,"K" \
        -a coordinates,TSK,c,c,"XLONG XLAT" \
        -a FieldType,SEAICE,c,i,104 \
        -a stagger,SEAICE,c,c,"M" \
        -a MemoryOrder,SEAICE,c,c,"XY" \
        -a description,SEAICE,c,c,"SEA ICE" \
        -a units,SEAICE,c,c,"-" \
        -a coordinates,SEAICE,c,c,"XLONG XLAT" \
        -a FieldType,SNOWH,c,i,104 \
        -a stagger,SNOWH,c,c,"M" \
        -a MemoryOrder,SNOWH,c,c,"XY" \
        -a description,SNOWH,c,c,"SNOW DEPTH" \
        -a units,SNOWH,c,c,"m" \
        -a coordinates,SNOWH,c,c,"XLONG XLAT" \
        -h --overwrite $outfile


echo 'Full nco script completed...your output file is: ' $outfile
