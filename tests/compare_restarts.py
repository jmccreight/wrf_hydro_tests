from glob import glob
import os
import subprocess
from sys import argv
import warnings

def compare_restarts(test_run_dir,ref_run_dir):
    restart_files=glob(test_run_dir+'/*RESTART*')
    hydro_files=glob(test_run_dir+'/*HYDRO_RST*')

    #Compare RESTART files
    restart_out = list()
    print('Comparing RESTART files')
    for test_run_file in restart_files:
        test_run_filename = os.path.basename(test_run_file)
        ref_run_file = glob(ref_run_dir+'/**/'+test_run_filename)
        if len(ref_run_file) == 0:
            warnings.warn(test_run_filename+' not found in reference run directory')
        else:
            print('Comparing file '+test_run_filename)
            restart_out.append(subprocess.run(['nccmp','-dmf',test_run_file,ref_run_file[0]],stderr=subprocess.STDOUT))

    #Compare HYDRO_RST files
    hydro_out = list()
    print('Comparing HYDRO_RST files')
    for test_run_file in hydro_files:
        test_run_filename = os.path.basename(test_run_file)
        ref_run_file = glob(ref_run_dir+'/**/'+test_run_filename)
        if len(ref_run_file) == 0:
            warnings.warn(test_run_filename+' not found in reference run directory')
        else:
            print('Comparing file '+test_run_filename)
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

def main():
    test_run_dir = argv[1]
    ref_run_dir = argv[2]
    compare_restarts(test_run_dir, ref_run_dir)

if __name__ == "__main__":
    main()