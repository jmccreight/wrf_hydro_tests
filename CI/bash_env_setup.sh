source candidate_spec.sh
source machine_spec.sh
source ../setup.sh

targetFile=foo.sh

# machine spec
echo "export WRF_HYDRO_TESTS_DIR=$WRF_HYDRO_TESTS_DIR " >> $targetFile
echo "export NETCDF=$NETCDF " >> $targetFile
echo "export WRF_HYDRO_RUN=$WRF_HYDRO_RUN " >> $targetFile

# candidate spec
echo "export WRF_HYDRO_TESTS_MACHINE_SPEC=$WRF_HYDRO_TESTS_MACHINE_SPEC " >> $targetFile
echo "export domainSourceDir=$domainSourceDir " >> $targetFile
echo "export domainRunDir=$domainRunDir " >> $targetFile
echo "export WRF_HYDRO_COMPILER=$WRF_HYDRO_COMPILER " >> $targetFile
echo "export nCoresDefault=$nCoresDefault " >> $targetFile
echo "export nCoresTest=$nCoresTest " >> $targetFile
echo "export WRF_HYDRO=$WRF_HYDRO " >> $targetFile
echo "export HYDRO_D=$HYDRO_D " >> $targetFile
echo "export SPATIAL_SOIL=$SPATIAL_SOIL " >> $targetFile
echo "export WRFIO_NCD_LARGE_FILE_SUPPORT=$WRFIO_NCD_LARGE_FILE_SUPPORT " >> $targetFile
echo "export WRF_HYDRO_RAPID=$WRF_HYDRO_RAPID " >> $targetFile
echo "export HYDRO_REALTIME=$HYDRO_REALTIME " >> $targetFile
echo "export NCEP_WCOSS=$NCEP_WCOSS " >> $targetFile
echo "export WRF_HYDRO_NUDGING=$WRF_HYDRO_NUDGING " >> $targetFile
echo "export REPO_DIR=$REPO_DIR " >> $targetFile
echo "export candidateFork=$candidateFork " >> $targetFile
echo "export candidateBranchCommit=$candidateBranchCommit " >> $targetFile
echo "export candidateLocalPath=$candidateLocalPath " >> $targetFile
echo "export referenceFork=$referenceFork " >> $targetFile
echo "export referenceBranchCommit=$referenceBranchCommit " >> $targetFile
echo "export referenceLocalPath=$referenceLocalPath " >> $targetFile

# setup
echo "export candidateRepoDir=$candidateRepoDir " >> $targetFile
echo "export refRepoDir=$refRepoDir " >> $targetFile
echo "export toolboxDir=$toolboxDir " >> $targetFile
echo "export answerKeyDir=$answerKeyDir " >> $targetFile
echo "export candidateBinary=$candidateBinary " >> $targetFile
echo "export referenceBinary=$referenceBinary " >> $targetFile
echo "export domainRunDir=$domainRunDir " >> $targetFile
echo "export authInfo=$authInfo " >> $targetFile
echo "export MACROS_FILE=$MACROS_FILE " >> $targetFile

