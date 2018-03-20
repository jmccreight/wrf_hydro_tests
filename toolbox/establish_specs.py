import yaml
import os
from boltons.iterutils import remap

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


def establish_user_spec(user_spec_file):
    user_spec = establish_spec(user_spec_file)
    return(user_spec)


# ######################################################
# Candidate spec


def establish_candidate(candidate_spec_file):

    candidate_spec = establish_spec(candidate_spec_file)

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
