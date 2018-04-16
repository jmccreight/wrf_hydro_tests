import subprocess
import os
from datetime import datetime
from color_logs import log

def log_boilerplate(candidate_spec, user_spec, env_vars, horiz_bar):

    log.debug( "Date                  : " + datetime.now().strftime('%Y %h %d %H:%M:%S %Z') )

    if not 'USER' in env_vars:
        user = subprocess.Popen(["whoami"], stdout=subprocess.PIPE).communicate()[0]
        env_vars['USER'] = user.decode('utf-8').replace("\n",'')
    log.debug( "User                  : " + env_vars['USER'] )

    if not 'HOSTNAME' in env_vars:
        hostname = subprocess.Popen(["hostname"], stdout=subprocess.PIPE).communicate()[0]
        env_vars['HOSTNAME'] = hostname.decode('utf-8').replace("\n",'')
    log.debug( "Machine               : " + env_vars['HOSTNAME'] )

    proc = subprocess.run(['git', 'rev-parse', 'HEAD'], stdout=subprocess.PIPE)
    the_commit = proc.stdout.decode('utf-8').split()[0]
    log.debug( "wrf_hydro_tests commit: " + the_commit )
    
    is_uncommitted = \
        subprocess.run(['git', 'diff-index', '--quiet', 'HEAD', '--']).returncode
    if is_uncommitted != 0:
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
