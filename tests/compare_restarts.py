from glob import glob
import os
import subprocess
test_run_dir = 'test_domain/run.1.new'
ref_run_dir = 'test_domain/run.2.old'

def compare_restarts(test_run_dir,ref_run_dir):
    restart_files=glob(test_run_dir+'/**/*RESTART*',recursive=True)
    hydro_files=glob(test_run_dir+'/**/*HYDRO_RST*',recursive=True)

    #Compare RESTART files
    restart_out = list()
    print('Comparing RESTART files')
    for test_run_file in restart_files:
        ref_run_file = glob(ref_run_dir+'/**/'+os.path.basename(test_run_file))
        restart_out.append(subprocess.run(['nccmp','-dmf',test_run_file,ref_run_file[0]],stderr=subprocess.STDOUT))

    #Compare HYDRO_RST files
    hydro_out = list()
    print('Comparing HYDRO_RST files')
    for test_run_file in hydro_files:
        ref_run_file = glob(ref_run_dir+'/**/'+os.path.basename(test_run_file))
        hydro_out.append(subprocess.run(['nccmp','-dmf',test_run_file,ref_run_file[0]],stderr=subprocess.STDOUT))

    #Check for exit codes and fail if non-zero
    for output in restart_out:
        if output.returncode == 1:
            print('One or more comparisons failed, see stdout log')
            exit(1)

    #Check for exit codes and fail if non-zero
    for output in hydro_out:
        if output.returncode == 1:
            print('One or more comparisons failed, see stdout log')
            exit(1)

    #If no errors exit with code 0
    print('All restart file comparisons pass')
    exit(0)

