export WRF_HYDRO_TESTS_DIR=/glade/u/home/jamesmcc/WRF_Hydro/wrf_hydro_tests
# REQUIRED
# The local path to the wrf_hydro_tests dir.


export GITHUB_SSH__PRIV_KEY=''
export GITHUB_AUTHTOKEN=`cat ~/.github_authtoken 2> /dev/null`
export GITHUB_USERNAME=jmccreight
# REQUIRED only if cloning any repositories from github.
# See wrf_hydro_tests/README.md for information and a suggestion on setting these. These can be inherited from the environment


## Your PBS header fields. Edit to your needs Do NOT include others here.
#PBS -m abe 
#PBS -M `whoami`@ucar.edu
#PBS -A NRAL0017

#######################################################
# Overrides to machine_spec.sh
# Place any environment variables you would like modified
# compared to the machine_spec.sh file.
