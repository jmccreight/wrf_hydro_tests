
source candidate_spec_intel_nwm_origin_nudging-fix_reg-origin-v1.2-updates.sh


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

