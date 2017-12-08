###################################
# WRF-Hydro Development docker
# Purpose:
#   Encapsulate the tools required for testing WRF-Hydro
# Authors: James McCreight, Joe Mills
# Email:  jamesmcc-at-ucar.edu, jmills@-at-car.edu
# Date:  11.2.2017
###################################
#Get the domain
FROM wrfhydro/domains:sixmile as domain
#Get the environment
FROM wrfhydro/dev
USER root

#Get all scripts and tests from local directory
RUN mkdir wrf_hydro_ci
COPY . wrf_hydro_ci/	

#Grab domain from previous domain layer
COPY --from=domain /test_domain wrf_hydro_ci/test_domain

#Move the domain into the testing folder
#RUN mv test_domain $HOME/wrf_hydro_ci

#Set workign directory
WORKDIR wrf_hydro_ci