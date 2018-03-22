#!/usr/bin/env python3
import os
import logging
from pprint import pprint, pformat

# Anything local/custom below here
import sys
sys.path.insert(0, 'toolbox/')
from color_logs import log
from establish_specs import *
from log_boilerplate import log_boilerplate
from establish_repo import *

sys.path.insert(0, 'tests/')
from fundamental import *

sys.path.insert(0, '/home/docker/wrf_hydro_py/wrfhydro/')
from wrf_hydro_model import *
from utilities import *


# ######################################################
# Help/docstring.

# ######################################################
# Agruments
#candidate_spec_file = str(argv[1])
#domain              = str(argv[2])
#test_spec           = str(argv[3])

candidate_spec_file = os.path.expanduser('~/wrf_hydro_tests/examples/nwm_ana/sixmile/docker/origin_reg-upstream/candidate_spec_GNU.yaml')
domain='/home/docker/domain/croton_NY'
config='NWM'
version='v1.2.1'
test_spec = 'fundamental'

# TODO JLM: want to get the log file name from the candidate_spec_file but want to be
#           logging to file before that. COPY the log file at the end.

# TODO JLM: generate default log file name. Hide it in a dot file and copy at end?
# TODO JLM: deal with relative and absolute paths, eg log file... 

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
log.info(horiz_bar)
log.info("*** take_test.py: A wrf_hydro candidate takes a test. ***")
log.debug('')

# ######################################################
# Specification files to dictionaries.
log.info(horiz_bar )
log.info( "Setup the specifictions (specs):")

env_vars       = os.environ.copy()

candidate_spec = establish_candidate(candidate_spec_file)
user_spec      = establish_user_spec(candidate_spec, env_vars)
machine_spec   = establish_machine_spec(candidate_spec, user_spec, env_vars)

# Test spec is a bit different.
# Writes to candidate_spec['wrf_hydro_tests']['test_spec']
establish_test(test_spec, candidate_spec, user_spec)

log.debug('')
# Some machine setup stuff... probably happens later...
# if [[ -z $NETCDF ]]; then 
#    export NETCDF="export NETCDF=\$(dirname `nc-config --includedir`)"
#fi


# ######################################################
# Log boilerplate info
log.info(horiz_bar )
log.info("Boilerplate:")
log_boilerplate(candidate_spec, user_spec, env_vars, horiz_bar)
log.debug('')


# ######################################################
# Repos setup
log.info(horiz_bar )
log.info("Establish repositories:")
establish_repo('candidate_repo', candidate_spec, user_spec)
establish_repo('reference_repo', candidate_spec, user_spec)
log.debug('')


# ######################################################
# Setup the test
log.info(horiz_bar)
log.info('Set up the test.')
log.debug('')
log.debug('Setup the domain.')
domain = WrfHydroDomain(domain_top_dir=domain, domain_config=config, model_version=version)
log.debug('')

log.debug('Setup the candidate model and simulation objects.')
candidate_model = WrfHydroModel(str(candidate_spec['candidate_repo']['local_path'])+'/trunk/NDHMS')
candidate_sim = WrfHydroSim(candidate_model,domain)
log.debug('Compile options:')
log.debug(pformat(candidate_model.compile_options))
log.debug('')

# TODO JLM: the trunk/NHDMS seems like a stupid add on... 
# TODO JLM: when did the path become a posix path object?

log.debug('Setup the reference model and simulation objects.')
reference_model = WrfHydroModel(str(candidate_spec['reference_repo']['local_path'])+'/trunk/NDHMS')
reference_sim = WrfHydroSim(reference_model,domain)
log.debug('')

# ######################################################
# Take the test.
#print(globals())
#exec(open(candidate_spec['wrf_hydro_tests']['test_spec'] ).read(),
#     globals=globals(), locals=local_dict)

# Assume the worst.
#exit_value = 1




# ######################################################
# Tear down
log.info('=================================================================')
log.info('Tear down test.')
log.debug('')
# TODO JLM: tear_down()
log.debug('')


# ######################################################
# Echo specs to log files
log.info('=================================================================')
log.info('*** take_test.py: Finished. ***')
log.debug('')
log.debug('Writing working specifications to ' + candidate_spec['log_file']+'.')
log.debug('')

# Kill the 'stdout' handler.
log.removeHandler(stdout)

log.info('*****************************************************************')
log.debug('')

# Protect the authtoken from printing to log files.
if not user_spec['github']['authtoken'] is None:
    user_spec['github']['authtoken'] = '*************************'

def log_spec(spec, name):
    log.info(horiz_bar)
    log.info(name+' spec: ')
    log.debug(pformat(spec))
    log.debug('')

all_specs = { 'Candidate': candidate_spec,
              'User': user_spec,
              'Machine': machine_spec }

for key, value in all_specs.items():
    log_spec(value, key)
