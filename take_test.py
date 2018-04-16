import pytest
from wrfhydropy import *
import os
import shutil
import logging
from pprint import pprint, pformat
import json
import sys
from copy import deepcopy

sys.path.insert(0, 'toolbox/')
from color_logs import log
from establish_specs import *
from log_boilerplate import log_boilerplate
from establish_repo import *
from establish_sched import get_sched_args_from_specs


# ######################################################
# Help/docstring.

# ######################################################
# Agruments
#candidate_spec_file = str(argv[1])
#domain              = str(argv[2])
#test_spec           = str(argv[3])

candidate_spec_file = os.path.expanduser('~/WRF_Hydro/wrf_hydro_tests/template_candidate_spec.yaml')
domain='/glade/p/work/jamesmcc/DOMAINS/croton_NY' #'/home/docker/domain/croton_lite'
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
#user_spec, machine_spec = establish_default_files()


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
#log.info(horiz_bar)
#log.info('Set up the test.')
#log.debug('')
#log.debug('Setup the domain.')
#domain = WrfHydroDomain(domain_top_dir=domain, domain_config=config, model_version=version)
#log.debug('')

#log.debug('Setup the candidate model and simulation objects.')
#candidate_model = WrfHydroModel(str(candidate_spec['candidate_repo']['local_path'])+'/trunk/NDHMS')
#candidate_sim = WrfHydroSim(candidate_model,domain)
#log.debug('Compile options:')
#log.debug(pformat(candidate_model.compile_options))
#log.debug('')

# TODO JLM: the trunk/NHDMS seems like a stupid add on... 
# TODO JLM: when did the path become a posix path object?

#log.debug('Setup the reference model and simulation objects.')
#reference_model = WrfHydroModel(str(candidate_spec['reference_repo']['local_path'])+'/trunk/NDHMS')
#reference_sim = WrfHydroSim(reference_model,domain)
#log.debug('')



# For each simulation
# {test_name}}
#   setup/input specs 
#     compiler
#     domain_config
#   job/output specs
# #ncores
# queue
# wall_time
# run_dir

# (PBS info from user spec)
# account
# email_who
# email_when

# machine info

# TODO, Each test suite (e.g. fundamental) has its functions to construct the necessary
# information in dict form for both its fixtures (setup) and for its tests.

specs_for_tests = dict()

# test_1_fundamental: >>>>>>>

setup_spec = { "compiler": candidate_spec['compiler'], "domain_config": config }

job_spec = get_sched_args_from_specs(
    machine_spec_file=candidate_spec['wrf_hydro_tests']['machine_spec'],
    user_spec_file=candidate_spec['wrf_hydro_tests']['user_spec'],
    candidate_spec_file=candidate_spec['wrf_hydro_tests']['candidate_spec']
)

test_1_fundamental = {

    "candidate_sim" : setup_spec
    "reference_sim" : setup_spect

    "test_compile_candidate" : { "compile_dir" : candidate_spec['test_dir'] + 'compile_candidate' },
    "test_compile_reference" : { "compile_dir" : candidate_spec['test_dir'] + 'compile_reference' },

    # These could be shallow copies?
    "test_run_candidate" : \
        deepcopy(job_spec).update({'job_name': 'test_run_candidate',
                                   'nproc'   : candidate_spec['n_cores']['default'],
                                   'run_dir' : candidate_spec['test_dir'] + '/run_candidate'}),

    "test_run_reference" : \
        deepcopy(job_spec).update({'job_name': 'test_run_reference',
                                   'nproc'   : candidate_spec['n_cores']['default'],
                                   'run_dir' : candidate_spec['test_dir'] + '/run_reference'}),

    "test_ncores_candidate" : \
        deepcopy(job_spec).update({'job_name': 'test_ncores_candidate',
                                   'nproc'   : candidate_spec['n_cores']['test'],
                                   'run_dir' : candidate_spec['test_dir'] + '/ncores_candidate'}),

    "test_perfrestart_candidate" : \
        deepcopy(job_spec).update({'job_name': 'test_perfrestart_candidate',
                                   'nproc'   : candidate_spec['n_cores']['default'],
                                   'run_dir' : candidate_spec['test_dir'] + '/restart_candidate'})

    }

specs_for_tests.update(test_1_fundamental)
# test_1_fundamental: <<<<<<

pytest_cmd = \
    [
      str(candidate_spec['candidate_repo']['local_path']),
      '-v',
      '--domain_dir',    domain,
      '--candidate_dir', str(candidate_spec['candidate_repo']['local_path']) + '/trunk/NDHMS',
      '--reference_dir', str(candidate_spec['reference_repo']['local_path']) + '/trunk/NDHMS',
      '--specs_for_tests', specs_for_tests
    ]
pytest.main(pytest_cmd)


# ######################################################
# Tear down
log.info('=================================================================')
log.info('Tear down test.')
log.debug('')
# TODO JLM: tear_down()
log.debug('')
#shutil.rmtree(candidate_spec['repos_dir'])
#shutil.rmtree(candidate_spec['test_dir'])


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
