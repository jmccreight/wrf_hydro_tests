echo '---------------------------------------------------------------------------'
echo "Machine spec group: "

echo WRF_HYDRO_TESTS_DIR:
echo $WRF_HYDRO_TESTS_DIR
echo

echo GITHUB_USERNAME:
echo $GITHUB_USERNAME
echo GITHUB_AUTHTOKEN:
echo '********************'
echo

echo WRF_HYDRO_MODULES:
echo $WRF_HYDRO_MODULES
echo

echo NETCDF:
echo $NETCDF
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
echo domainSourceDir:
echo $domainSourceDir
echo

echo domainRunDir:
echo $domainRunDir
echo

echo '* Compiler *'
echo WRF_HYDRO_COMPILER:
echo $WRF_HYDRO_COMPILER
echo

echo '* Run Group*'
echo TEST_WALL_TIME:
echo $TEST_WALL_TIME
echo

echo nCoresDefault:
echo $nCoresDefault
echo

echo nCoresTest:
echo $nCoresTest
echo

echo '* Model compile options *'
echo WRF_HYDRO:
echo $WRF_HYDRO
echo HYDRO_D:
echo $HYDRO_D
echo SPATIAL_SOIL:
echo $SPATIAL_SOIL
echo WRFIO_NCD_LARGE_FILE_SUPPORT:
echo $WRFIO_NCD_LARGE_FILE_SUPPORT
echo WRF_HYDRO_RAPID:
echo $WRF_HYDRO_RAPID
echo HYDRO_REALTIME:
echo $HYDRO_REALTIME
echo NCEP_WCOSS:
echo $NCEP_WCOSS
echo WRF_HYDRO_NUDGING:
echo $WRF_HYDRO_NUDGING
echo

echo '* Repo Groups *'
echo REPO_DIR:
echo $REPO_DIR
echo

echo '** Candidate repo subgroup **'
echo candidateFork:
echo $candidateFork
echo candidateBranchCommit:
echo $candidateBranchCommit
echo candidateLocalPath:
echo $candidateLocalPath
echo

echo '** Reference repo subgroup **'
echo referenceFork:
echo $referenceFork
echo referenceBranchCommit:
echo $referenceBranchCommit
echo referenceLocalPath:
echo $referenceLocalPath
echo
