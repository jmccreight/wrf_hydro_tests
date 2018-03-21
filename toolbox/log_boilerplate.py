import pygit2
import subprocess
import os
from datetime import datetime
from color_logs import log

def log_boilerplate(candidate_spec, user_spec, env_vars, horiz_bar):

    log.debug( "Date                  : " + datetime.now().strftime('%Y %h %d %H:%M:%S %Z') )
    log.debug( "User                  : " + env_vars['USER'] )

    if not 'HOSTNAME' in env_vars:
        hostname = subprocess.Popen(["hostname"], stdout=subprocess.PIPE).communicate()[0]
        env_vars['HOSTNAME'] = hostname.decode('utf-8').replace("\n",'')
    log.debug( "Machine               : " + env_vars['HOSTNAME'] )

    wrf_hydro_tests_repo = pygit2.Repository(user_spec['wrf_hydro_tests_dir'])
    wrf_hydro_tests_commit = wrf_hydro_tests_repo.revparse_single('HEAD').hex
    wrf_hydro_tests_uncommitted = wrf_hydro_tests_repo.diff().stats.files_changed > 0
    log.debug( "wrf_hydro_tests commit: " + wrf_hydro_tests_commit )
    if wrf_hydro_tests_uncommitted:
        log.warning( "There are uncommitted changes to wrf_hydro_tests.")

    log.debug( "Candidate spec file   : " + candidate_spec['wrf_hydro_tests']['candidate_spec'] )

    log.debug( "Machine spec file     : " + candidate_spec['wrf_hydro_tests']['machine_spec'] )
    log.debug( "Machine spec set by   : " +
               candidate_spec['wrf_hydro_tests']['machine_spec_setby'] )

    log.debug( "User spec file        : " + candidate_spec['wrf_hydro_tests']['user_spec'] )
    log.debug( "User spec set by      : " +
               candidate_spec['wrf_hydro_tests']['user_spec_setby'] )

    log.debug( "Test spec file        : " + candidate_spec['wrf_hydro_tests']['test_spec'] )
    log.debug( "Test spec set by      : " +
               candidate_spec['wrf_hydro_tests']['test_spec_setby'] )

    log.debug( "Log file              : ")
    log.debug( "Will echo specs to log at end.")
    return(True)
