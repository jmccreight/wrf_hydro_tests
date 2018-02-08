
source candidate_spec_intel.sh


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# OVERRIDES the above sourcing.

###########################################################################
# * Compiler * 

export WRF_HYDRO_COMPILER='GNU'
## Default = 'GNU'
## Choices are currently 'GNU' and 'intel'. (currently case-sensitive).


#####################################################################################

export TEST_WALL_TIME=00:05
## The wall time to use with a job scheduler.

