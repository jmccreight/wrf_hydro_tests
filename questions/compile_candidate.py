import os
import logging
from pprint import pprint, pformat
# Anything local/custom below here
import sys
sys.path.insert(0, '../toolbox/')
from color_logs import log
from establish_specs import *
from log_boilerplate import log_boilerplate
from establish_repo import *

# Compile question
def test_compile_candidate(myself, compiler: str,
                           overwrite: bool = False,
                           compile_options: dict = None):
    try:
        #print('Candidate compile test')
        compile_dir = myself.output_dir.joinpath('compile_candidate')

        # Compile the model
        myself.candidate_sim.model.compile(compiler,
                                         compile_dir,
                                         overwrite,
                                         compile_options)

        # Check compilation status
        if myself.candidate_sim.model.compile_log.returncode != 0:
            myself.results.update({'compile_candidate':'fail'})
            myself.exit_code = 1
        else:
            myself.results.update({'compile_candidate':'pass'})
            #print('Test completed')

    except Exception as e:
        warnings.warn('Candidate compile test did not complete: ')
        print(e)
        myself.results.update({'compile_candidate': 'fail'})
        myself.exit_code = 1
