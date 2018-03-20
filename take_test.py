import os
import logging
from pprint import pprint
# Anything local/custom below here
from color_logs import log
from establish_candidate import establish_candidate

# ######################################################
# Help/docstring.

# ######################################################
# Agruments
#candidate_spec_file = str(argv[1])
domain              = str(argv[2])
test_spec           = str(argv[3])

candidate_spec_file = '/Users/jamesmcc/WRF_Hydro/wrf_hydro_tests/examples/nwm_ana/sixmile/docker/origin_reg-upstream/candidate_spec_GNU.yaml'

# ######################################################
# Logging setup. 
# This coloring approach may only allow one log.
log.setLevel(logging.DEBUG)

stdout = logging.StreamHandler()
stdout.setLevel(logging.DEBUG)
log.addHandler(stdout)

log_file = logging.FileHandler("example.log")
log_file.setLevel(logging.DEBUG)
log.addHandler(log_file)

log.debug(   "Debug level information, details.")
log.info(    "Info = success level information. ")
log.warning( "Warning level information.")
log.critical("Critical level information.")
log.error(   "Error level information.")

# ######################################################
# Bring in environment variables (make a copy, not sure it matters).
env_vars = os.environ.copy

# ######################################################
# Candidate spec file parsing to candidate_spec
candidate_spec = establish_candidate(candidate_spec_file, env_vars)

