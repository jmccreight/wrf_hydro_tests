import os
import logging
from pprint import pprint
import pygit2
import sys
# Anything local/custom below here
sys.path.insert(0, 'toolbox/')
from color_logs import log
from establish_specs import *

# ######################################################
# Help/docstring.

# ######################################################
# Agruments
#candidate_spec_file = str(argv[1])
domain              = str(argv[2])
test_spec           = str(argv[3])

candidate_spec_file = '/Users/james/WRF_Hydro/wrf_hydro_tests/examples/nwm_ana/sixmile/docker/origin_reg-upstream/candidate_spec_GNU.yaml'

# ######################################################
# Logging setup. 
# This coloring approach may only allow one log.
log.setLevel(logging.DEBUG)

stdout = logging.StreamHandler()
stdout.setLevel(logging.DEBUG)
log.addHandler(stdout)

log_file = "example.log"
log_file_handler = logging.FileHandler(log_file)
log_file_handler.setLevel(logging.DEBUG)
log.addHandler(log_file_handler)

horiz_bar='================================================================='

#log.debug(   "Debug level information, details.")
#log.info(    "Info = success level information. ")
#log.warning( "Warning level information.")
#log.critical("Critical level information.")
#log.error(   "Error level information.")

# ######################################################
# Bring in environment variables (make a copy, not sure it matters).
env_vars = os.environ.copy()

# ######################################################
# Candidate spec file parsing to candidate_spec
candidate_spec = establish_candidate(candidate_spec_file)

# ######################################################
# User spec file.

if ('wrf_hydro_tests' in candidate_spec) and \
   ('user_spec' in candidate_spec['wrf_hydro_tests']):
    user_spec_file = candidate_spec['wrf_hydro_tests']['user_spec']
else:
    if 'WRF_HYDRO_TESTS_USER_SPEC' in env_vars: 
        user_spec_file = env_vars['WRF_HYDRO_TESTS_USER_SPEC']
    else:
        user_spec_file = os.path.expanduser('~/.wrf_hydro_tests_user_spec.sh')

user_spec = establish_user_spec(user_spec_file)
# WARN if DNE

# ######################################################
# Marchine spec file
if ('wrf_hydro_tests_dir' in user_spec):
    machine_spec_file = user_spec['wrf_hydro_tests_dir']/machine_spec.sh
else:
    machine_spec_file = env_vars['WRF_HYDRO_TESTS_MACHINE_SPEC']

machine_spec = establish_machine_spec(user_spec_file)

# ######################################################
# Test specification.


# ######################################################
# Get the commit of the testing repo being used. 
# And if there are uncommitted changes (to the index)
wrf_hydro_tests_repo = pygit2.Repository(user_spec['wrf_hydro_tests_dir'])
wrf_hydro_tests_commit = wrf_hydro_tests_repo.revparse_single('HEAD').hex
wrf_hydro_tests_uncommitted = wrf_hydro_tests_repo.diff().stats.files_changed > 0

# Assume the worst.
exit_value = 1

log.debug('')
log.debug('')
log.info(horiz_bar)


