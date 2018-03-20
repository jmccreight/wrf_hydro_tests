## Boiler plate
log.info('')
log.info(horiz_bar )

log.info("take_test.py: A wrf_hydro candidate takes a test.")
log.info('')
log.info( "Boilerplate:")
log.info( "Date                  : "+datetime.datetime.now().strftime('%Y %h %d %H:%M:%S %Z') )
log.info( "User                  : " + env_vars['USER'] )
log.info( "Machine               : " + env_vars['HOSTNAME'] )
log.info( "wrf_hydro_tests commit: " + wrf_hydro_tests_commit )
if wrf_hydro_tests_uncommitted:
    log.info( "There are uncommitted changes to wrf_hydro_tests.")

log.info( "machine spec file     : " $WRF_HYDRO_TESTS_MACHINE_SPEC )
log.info( "candidateSpecFile     : " + candidate_spec_file )
log.info( "testSpecFile          : " $testSpecFile    
log.info( "Log file              : " 
log.info( "Will echo candidateSpecFile to log at end."            
