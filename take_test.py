
# # Establish docker.
# #docker create --name croton_2 wrfhydro/domains:croton_NY
# disk_dir='chimayoSpace'
# if [ $HOSTNAME = yucatan.local ]; then disk_dir=jamesmcc; fi
# host_repos=/Volumes/d1/${disk_dir}/git_repos

# # # Start the image
# docker run -it \
#     -e USER=docker \
#     -e GITHUB_AUTHTOKEN=$GITHUB_AUTHTOKEN \
#     -e GITHUB_USERNAME=$GITHUB_USERNAME \
#     -e WRF_HYDRO_TESTS_USER_SPEC=/home/docker/wrf_hydro_tests/.wrf_hydro_tests_user_spec.yaml \
#     -v ${host_repos}/wrf_hydro_nwm_myFork:/home/docker/wrf_hydro_nwm_myFork \
#     -v ${host_repos}/wrf_hydro_py:/home/docker/wrf_hydro_py \
#     -v ${host_repos}/wrf_hydro_tests:/home/docker/wrf_hydro_tests \
#     -v /Users/jamesmcc/Downloads/croton_NY:/croton_NY --volumes-from croton_2 \
#     wrfhydro/dev:conda

# # Inside docker
# cd ~/wrf_hydro_py/
# pip uninstall -y wrfhydropy
# pip install termcolor
# python setup.py develop
# cd ~/wrf_hydro_tests
# python

#######################################################

import code
import copy
import json
import logging
import os
from pprint import pprint, pformat
import pytest
import shutil
import sys
import wrfhydropy

sys.path.insert(0, '/home/docker/wrf_hydro_tests/toolbox/')
from color_logs import log
from establish_specs import *
from log_boilerplate import log_boilerplate
from establish_repo import *

# ######################################################
# Help/docstring.

# ######################################################
# Agruments
#candidate_spec_file = str(argv[1])
#domain              = str(argv[2])
#test_spec           = str(argv[3])

candidate_spec_file = os.path.expanduser('/home/docker/wrf_hydro_tests/template_candidate_spec.yaml')
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

# ###################################
machine_name = wrfhydropy.core.job_tools.get_machine()
if machine_name == 'docker':
    default_scheduler = None
else:
    default_scheduler = wrfhydropy.Scheduler(
        job_name='default',
        account=user_spec['PBS']['account'],
        walltime=candidate_spec['wall_time'],
        queue=candidate_spec['queue'],
        nproc=candidate_spec['n_cores'],
        ppn=machine_spec[machine_name]['cores_per_node']
    )
    default_scheduler = json.dumps(default_scheduler.__dict__)

job_default = wrfhydropy.Job(nproc=candidate_spec['n_cores']['default'])
job_ncores=copy.deepcopy(job_default)
job_ncores.nproc=candidate_spec['n_cores']['test']
job_default = json.dumps(job_default.__dict__)
job_ncores = json.dumps(job_ncores.__dict__)

pytest_cmd = [
    '--config', config,
    '--compiler', candidate_spec['compiler'],
    '--domain_dir', domain,
    '--output_dir',  candidate_spec['test_dir'],
    '--candidate_dir', str(candidate_spec['candidate_repo']['local_path']) + '/trunk/NDHMS',
    '--reference_dir', str(candidate_spec['reference_repo']['local_path']) + '/trunk/NDHMS',
    '--job_default', job_default,
    '--job_ncores', job_ncores,
    '--scheduler', default_scheduler,
]

pytest.main(pytest_cmd)
code.interact(local=locals())


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
