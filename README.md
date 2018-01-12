# wrf\_hydro\_tests #

Testing for the WRF-Hydro model.
Testing for the price of compiling: This should completely replace your WRF-Hydro compile process on all machines. 

# Overview

take\_test(candidate, test) 
  setup candidate
  test
   question1, answer1
   ...
   questionN, answerN
   questionN+1, diagnostic1
   ... 
   questionN+M, diagnosticM
   take_down candidate

A candidate takes a test.  A candidate is described by a copy of 
candidate\_template.sh which may have another name. Candidates have 
lots of different moving parts, including machine, domain, commit 
while the underlying tests remain the same.

Take\_test requires a "candidate specification file" and a "test file". If no candidate
file is supplied, the necessary candidate variables/info are looked
for in the environment.

Inside take\_test:
	* The candidate is instantiated by setup.sh.
	* A test is comprised of questions (You can make your own custom
      tests from existing questions or make your own questions). 
	* Questions are comprised of premises (given a, b, c) and may or may
	  not have answers (you can make custom questions too). 
	* The answer_key is invoked (by the question) to see if the testee's answers are
	  correct. 
	* Questions with answers should be ordered from most fundamental to
	  least fundamental and the test stops with the first failure. 
	* Questions without answers come at the end and only return
	  diagnostic/qualitative information.

questions/ 
	* are only about the candidate. (E.g. for a regression test, the
      question is about the candidate: does the candidate run 
	  match the reference run. All parts of compiling and running the 
	  reference binary should be contained in the question about
	  the regression of the candidate.)
	* should be summarized at the top of each question file. 
	* have defined run directory names that must be adhered to when
      constructing domains. 
	* 


# Running tests

For now, testing (actually, configuration) requires two repos. 

Testing is intended to work

1) locally (e.g. cheyenne) 
2) on Docker containers (e.g. your desktop), and
3) CircleCI 

using the approach in this repo with minor adaptations for each
application. 

Testing currently depends on a suite of environment variables. 

Required:

Environment Variable   | Description 
---                    |---
WRF\_HYDRO\_TESTS\_DIR | The local path to the wrf\_hydro\_tests dir.
REPO\_DIR              | Where repositories cloned from github shall be placed (in subfolders)
domainSourceDir        | Where the domain and pre-established run directories live.
testName               | A valid subdirectory of wrf\_hydro\_tests/tests where desired test lives.
WRF_HYDRO              | Compile time option to the model (1 for off-line runs)
NETCDF                 | Where NetCDF resides on your system


Optional:

Environment Variable   | Description 
---                    |---
domainTestDir          |If not running in Docker, clone the domainSourceDir here to keep the original clean. 
**Model group:**       |
HYDRO_D SPATIAL_SOIL   | See model reference for these
WRFIO_NCD_LARGE_FILE_SUPPORT | " "
WRF_HYDRO_RAPID        | " "
HYDRO_REALTIME         | " "(may be defunct now)
NCEP_WCOSS             | " "
WRF_HYDRO_NUDGING      | " "
**Github group:** | If getting repositories from github.
GITHUB\_USERNAME       |If cloning repositories from github, these are required.
GITHUB\_AUTHTOKEN      |for above user on github (see below for details)
**Test group:**  | Testing repository is the one you have been working on. It may come from github or a local path.
testFork               |A named fork on github. Default = ${GITHUB\_USERNAME}/wrf\_hydro\_nwm
testBranchCommit       |A branch or commit on testFork. Default = master
_OR_ |
testLocalPath          |A path on local machine where the current state of the repo (potentially uncommitted) is compiled. This supercedes BOTH testFork and testBranchCommit if set. Default =''
**Reference group:** | Reference repository is the one that provides the reference for regression testing. It may come from github or a local path.
referenceFork          |A named fork on github. Default = NCAR/wrf\_hydro\_nwm
referenceBranchCommit  |A branch or commit on referenceFork. Default = master   
_OR_ |
referenceLocalPath     |A path on local machine where the current state of the repo (potentially uncommitted) is compiled. This supercedes BOTH referenceFork and referenceBranchCommit if set. Default =''


## Examples

See the examples directory. 

## Managing the GITHUB environment variables. 
Configure your ~/.bashrc with the following

```
export GITHUB_AUTHTOKEN=`cat ~/.github_authtoken 2> /dev/null`
export GITHUB_USERNAME=jmccreight
```

The file `~/.github_authtoken` should be READ-ONLY BY OWNER (500). For example:

```
jamesmcc@chimayo[736]:~/WRF_Hydro/wrf_hydro_docker/testing> ls -l ~/.github_authtoken 
-r--------  1 jamesmcc  rap  40 Nov  3 10:18 /Users/jamesmcc/.github_authtoken
```

The file contains the user authtoken from github with no carriage return or other 
whitespace in the file. See 

[https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/]

for information on getting your github authtoken.

## Contributing
