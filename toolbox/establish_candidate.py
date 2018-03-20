import subprocess
import yaml
import functools
import collections

def establish_candidate(candidate_spec_file):
    with open(candidate_spec_file) as ff:
        candidate_spec_dict = yaml.safe_load(ff)
        

    # Keep as a dict or transform to an object?
    # candidate_spec = munchify(candidate_spec_dict)
    candidate_spec = candidate_spec_dict
    
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
