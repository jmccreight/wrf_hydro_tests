import yaml
import os
from boltons.iterutils import remap
from color_logs import log

# A few generic utils followed by functions for individual spec files which
# can acommodate customization.

# ######################################################
# Remapping nested values
# http://sedimental.org/remap.html


def visit(path, key, value):
    if isinstance(value, str):
        return key, os.path.expanduser(os.path.expandvars(value))
    return key, value


def remap_spec(spec_file):
    return(remap(spec_file, visit))

# ######################################################
# Generic spec establishment = YAML + remap_spec

def establish_spec(spec_file):
    """Parse YAML and expand  ~ and $ 
    """
    with open(spec_file) as ff:
        spec_dict = yaml.safe_load(ff)

    spec = remap_spec(spec_dict)

    return(spec)


# ######################################################
# User spec


def establish_user_spec(candidate_spec, env_vars):
    log.info('Establish user spec.')

    user_spec_file = None
    if ('wrf_hydro_tests' in candidate_spec) and \
       ('user_spec'       in candidate_spec['wrf_hydro_tests']):
        user_spec_file = candidate_spec['wrf_hydro_tests']['user_spec']

    if user_spec_file == '' or user_spec_file is None:
        if 'WRF_HYDRO_TESTS_USER_SPEC' in env_vars:
            user_spec_file = env_vars['WRF_HYDRO_TESTS_USER_SPEC']
        else:
            user_spec_file = os.path.expanduser('~/.wrf_hydro_tests_user_spec.sh')

    candidate_spec['wrf_hydro_tests']['user_spec'] = user_spec_file
    # TODO JLM: WARN if DNE

    user_spec = establish_spec(user_spec_file)

    return(user_spec)


# ######################################################
# Machine spec


def establish_machine_spec(candidate_spec, user_spec, env_vars):
    log.info('Establish machine spec.')

    if ('wrf_hydro_tests_dir' in user_spec):
        machine_spec_file = user_spec['wrf_hydro_tests_dir']+'/machine_spec.yaml'
    else:
        machine_spec_file = env_vars['WRF_HYDRO_TESTS_MACHINE_SPEC']

    candidate_spec['wrf_hydro_tests']['machine_spec'] = machine_spec_file
    machine_spec = establish_spec(machine_spec_file)

    # TODO JLM: User spec is supposed to allow overrides to machine spec.
    # Apply overrides from user_spec

    return(machine_spec)


# ######################################################
# Candidate spec


def establish_candidate(candidate_spec_file):
    log.info('Establish candidate spec.')
    candidate_spec = establish_spec(candidate_spec_file)
    candidate_spec['wrf_hydro_tests']['candidate_spec'] = candidate_spec_file
    # Keep as a dict or transform to an object?
    # candidate_spec = munchify(candidate_spec_dict)
    # candidate_spec = candidate_spec_dict

    # verify the candidate_spec ?
    # How much of this should just be left to later failures?
    #{'candidate_repo': {'commitish': 'master',
    #                    'fork': 'NCAR/wrf_hydro_nwm',
    #                    'local_path': ''},
    # 'compiler': 'GNU',
    # 'n_cores': Munch({'default': 2, 'test': 1}),
    # 'reference_repo': {'commitish': 'master',
    #                    'fork': '${GITHUB_USERNAME}/wrf_hydro_nwm',
    #                    'local_path': ''},
    # 'repos_dir': '~/test_repos',
    # 'wall_time': '00:05',
    # 'wrf_hydro_tests': {'machine_spec': '',
    #                     'user_spec': '/test_specs_logs/user_spec.sh'}}
    return(candidate_spec)
