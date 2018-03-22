import pathlib
import shutil
import datetime as dt
import pickle
from pprint import pprint
import warnings
import sys
sys.path.insert(0, 'toolbox/')
from color_logs import log
sys.path.insert(0, 'questions/')
from compile_candidate import *
sys.path.insert(0, '/home/docker/wrf_hydro_py/wrfhydro/utilities/')
sys.path.insert(0, '/home/docker/wrf_hydro_py/wrfhydro/')
from utilities import *
import copy


class FundamentalTest(object):
    def __init__(self,candidate_sim,reference_sim,output_dir,overwrite = False):
        self.candidate_sim = copy.deepcopy(candidate_sim)
        self.reference_sim = copy.deepcopy(reference_sim)
        self.output_dir = pathlib.Path(output_dir)
        self.results = {}
        self.exit_code = None

        if self.output_dir.is_dir() is False:
            self.output_dir.mkdir(parents=True)
        else:
            if self.output_dir.is_dir() is True and overwrite is True:
                shutil.rmtree(str(self.output_dir))
                self.output_dir.mkdir()
            else:
                raise IOError(str(self.output_dir) + ' directory already exists')

        ###########
        # Enforce some namelist options up front

        # Make sure the lsm and hydro restart output timesteps are the same
        hydro_rst_dt = self.candidate_sim.hydro_namelist['hydro_nlist']['rst_dt']
        self.candidate_sim.namelist_hrldas['noahlsm_offline']['restart_frequency_hours'] = int(hydro_rst_dt/60)

    def compile_candidate(self, compiler: str,
                               overwrite: bool = False,
                                compile_options: dict = None):
        test_compile_candidate(self, compiler, overwrite, compile_options)



horiz_bar = '================================================================='

log.info(horiz_bar)
log.info('Take the test.')
log.debug('')
test = FundamentalTest(candidate_sim, reference_sim, '/home/docker/test', overwrite=True)

# TODO JLM: wrf_hydro_py, print compile log on compile fail.
log.info('C')
log.debug('')
test.compile_candidate(candidate_spec['compiler'])
print(test.candidate_sim.model.compile_log.stdout.decode('utf-8'))
