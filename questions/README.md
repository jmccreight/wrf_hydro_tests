# Questions

This README scrapes documentation from the individual questions to
provide a quick reference (alternative to surfing all the codes) when
building new tests and domains. Information in individual question
files contained in this directory where the lines begin exactly as
follows: 

##q

will be collected and placed below. The script
scrape\_question\_metadata.sh simply applies a strict regex for
getting these and goes through the files in the order specified. 

The scraped info appears below. 

-----------------------------------------------------------------

## compile.sh
Compile Candidate Binary
Question: Does the candidate binary compile?
Directory: Either $REPO_DIR/candidate (if code is remote), or
           $candidateLocalPath if code is local.

## run.sh
Run Candidate Binary
Question: Does the candidate binary run to completion?
Directory: $domainRunDir/run.candidate
Compares: The number of diag_hydro files with the
          "The model finished successfully..."
          to the number of cores used in the run.

## perfect_restart.sh
Perfect Restart of Candidate Binary
Question: Does a restart of the model yield an identical restart file at a later time?
Directories:
   Candidate Run        : $domainRunDir/run.candidate
   Candidate Restart run: $domainRunDir/run.candidate.restart

## number_of_cores.sh
Candidate # Cores Test
Question: Does the result depend on the number of cores used for MPI?
Directories:
   Run with nCoresDefault: $domainRunDir/run.candidate
   Run with nCoresTest:    $domainRunDir/run.candidate.ncores_test
Compares: All restart files RESTART, HYDRO_RST, and nudging (if available). 

## regression.sh
Candidate Regression Test
Question: Does the Candidate run match a reference run?
Directories:
   reference compile: Either $REPO_DIR/reference (if code is remote), or
                      $referenceLocalPath if code is local.
   reference run    : $domainRunDir/run.reference
Compares: All restart files RESTART, HYDRO_RST, and nudging (if available). 

## channel-only_matches_full.sh
