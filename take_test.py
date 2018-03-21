#!/usr/bin/env python3

import os
import logging
from pprint import pprint
import sys
# Anything local/custom below here
sys.path.insert(0, 'toolbox/')
from color_logs import log
from establish_specs import *
from log_boilerplate import log_boilerplate

# ######################################################
# Help/docstring.

# ######################################################
# Agruments
#candidate_spec_file = str(argv[1])
#domain              = str(argv[2])
#test_spec           = str(argv[3])

candidate_spec_file = os.path.expanduser('~/WRF_Hydro/wrf_hydro_tests/examples/nwm_ana/sixmile/docker/origin_reg-upstream/candidate_spec_GNU.yaml')
# TODO JLM: want to get the log file name from the candidate_spec_file but want to be
#           logging to file before that. COPY the log file at the end.


# ######################################################
# Logging setup. 
# This coloring approach may only allow one log.
log.setLevel(logging.DEBUG)

stdout = logging.StreamHandler()
stdout.setLevel(logging.DEBUG)
log.addHandler(stdout)

log_file = "example.log"
log_file_handler = logging.FileHandler(log_file, mode='w')
log_file_handler.setLevel(logging.DEBUG)
log.addHandler(log_file_handler)

horiz_bar = '================================================================='
log.info(horiz_bar )
log.info("take_test.py: A wrf_hydro candidate takes a test.")
log.info('')


# ######################################################
# Bring in environment variables (make a copy, not sure it matters).


# ######################################################
# Specification files to dictionaries.
# The candidate_spec file 

env_vars       = os.environ.copy()
candidate_spec = establish_candidate(candidate_spec_file)
user_spec      = establish_user_spec(candidate_spec, env_vars)
machine_spec   = establish_machine_spec(candidate_spec, user_spec, env_vars)

# Some machine setup stuff... probably happens later...
# if [[ -z $NETCDF ]]; then 
#    export NETCDF="export NETCDF=\$(dirname `nc-config --includedir`)"
#fi


# ######################################################
# Boilerplate
log_boilerplate(candidate_spec, user_spec, env_vars, horiz_bar)


# ######################################################
# Test specification.


# ######################################################
# Get the commit of the testing repo being used,
# and if there are uncommitted changes (to the index).

# Assume the worst.
exit_value = 1



