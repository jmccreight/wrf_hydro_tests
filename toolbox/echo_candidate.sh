echo '---------------------------------------------------------------------------'
echo "Machine spec group: "

echo WRF_HYDRO_TESTS_DIR = $WRF_HYDRO_TESTS_DIR
echo

echo GITHUB_USERNAME = $GITHUB_USERNAME
echo GITHUB_AUTHTOKEN = '********************'
echo

echo WRF_HYDRO_MODULES = $WRF_HYDRO_MODULES
echo

echo NETCDF = $NETCDF
echo

echo '* Run group *'
echo WRF_HYDRO_RUN:
type $WRF_HYDRO_RUN
echo

echo
echo '---------------------------------------------------------------------------'
echo "Candidate spec file group: "
echo
echo '* Domain Group *'
echo domainSourceDir = $domainSourceDir
echo

echo domainRunDir = $domainRunDir
echo

echo '* Compiler *'
echo WRF_HYDRO_COMPILER = $WRF_HYDRO_COMPILER
echo

echo '* Run Group*'
echo TEST_WALL_TIME = $TEST_WALL_TIME
echo

echo nCoresDefault = $nCoresDefault
echo

echo nCoresTest = $nCoresTest
echo

echo '* Model compile options *'
echo WRF_HYDRO = $WRF_HYDRO
echo HYDRO_D = $HYDRO_D
echo SPATIAL_SOIL = $SPATIAL_SOIL
echo WRFIO_NCD_LARGE_FILE_SUPPORT = $WRFIO_NCD_LARGE_FILE_SUPPORT
echo WRF_HYDRO_RAPID = $WRF_HYDRO_RAPID
echo HYDRO_REALTIME = $HYDRO_REALTIME
echo NCEP_WCOSS = $NCEP_WCOSS
echo WRF_HYDRO_NUDGING = $WRF_HYDRO_NUDGING
echo

echo '* Repo Groups *'
echo REPO_DIR = $REPO_DIR
echo

echo '** Candidate repo subgroup **'
echo candidateFork = $candidateFork
echo candidateBranchCommit = $candidateBranchCommit
echo candidateLocalPath = $candidateLocalPath
echo

echo '** Reference repo subgroup **'
echo referenceFork = $referenceFork
echo referenceBranchCommit = $referenceBranchCommit
echo referenceLocalPath = $referenceLocalPath
echo
