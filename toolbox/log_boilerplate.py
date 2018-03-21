import pygit2
import subprocess
import os
from datetime import datetime
from color_logs import log

def log_boilerplate(candidate_spec, user_spec, env_vars, horiz_bar):

    log.info(horiz_bar )
    log.info( "Boilerplate:")
    log.info( "Date                  : " + datetime.now().strftime('%Y %h %d %H:%M:%S %Z') )
    log.info( "User                  : " + env_vars['USER'] )

    if not 'HOSTNAME' in env_vars:
        hostname = subprocess.Popen(["hostname"], stdout=subprocess.PIPE).communicate()[0]
        env_vars['HOSTNAME'] = hostname.decode('utf-8').replace("\n",'')
    log.info( "Machine               : " + env_vars['HOSTNAME'] )

    wrf_hydro_tests_repo = pygit2.Repository(user_spec['wrf_hydro_tests_dir'])
    wrf_hydro_tests_commit = wrf_hydro_tests_repo.revparse_single('HEAD').hex
    wrf_hydro_tests_uncommitted = wrf_hydro_tests_repo.diff().stats.files_changed > 0
    log.info( "wrf_hydro_tests commit: " + wrf_hydro_tests_commit )
    if wrf_hydro_tests_uncommitted:
        log.info( "There are uncommitted changes to wrf_hydro_tests.")

    log.info( "candidate spec file   : " + candidate_spec['wrf_hydro_tests']['candidate_spec'] )
    log.info( "machine spec file     : " + candidate_spec['wrf_hydro_tests']['machine_spec'] )
    log.info( "user spec file        : " + candidate_spec['wrf_hydro_tests']['user_spec'] )
    #log.info( "testSpecFile          : " $testSpecFile    
    log.info( "Log file              : ")
    log.info( "Will echo specs to log at end.")
    log.info('')
