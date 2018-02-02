# wrf\_hydro\_tests: Testing for the WRF-Hydro model. #

Why use wrf\_hydro\_tests?

_Testing for the price of compiling:_ Developers can run engineering
tests with each compile with minimal added overhead when using toy
domains. This IS the way for developers to compile.

_Testing on a machine near you:_ This code is meant to work on any
linux distribution. The requirements are bash, python3, and the
dependencies of the WRF-Hydro model. It has been run on Docker and on
Chyenne (using qsub requires the wrf\_hydro\_tools repository at this
time) and is meant to be highly protable between different environments. 

# Overview / Definitions #

Purpose of this section

1. Define terms ("test" can be in multiple, ambiguous ways),
1. Give the user an idea of how to "take_tests",

## take_test.sh ##

A *candidate* takes a *test*. The take\_test name emphasizes that there
are two parts: the taker and the test. The take_test script is a
top-level driver routine which brings the two together and handles:

    1. Logging
    1. Setup of the candidate
    1. Taking of the test
    1. Tearing down the candidate (optional).
    1. Exiting

## The candidate ##

A *candidate* is ALL the particulars of what is necessary to take a
test. The candidate consists of two files:

    1. The machine specification file, which is nearly static for a given
       machine. 
    1. The


The candidate specification file
(candidate\_spec\_file\_template.sh) is tailored by the user to specifiy the
candidate. Broadly, these are the groups of "moving parts" or
uniqueness to be specified for a candidate: 

1. Domain Group
1. Machine Group : static configuration for each machine?
1. Model Group
1. Numer of Cores Group
1. *Github group* Could be removed as it is nearly static.
1. Repository Groups (2)

There are currently a total of 25 variables in these 6 groups. Many are
optional. We believe these uniquely identify a *candidate*. If you
dont find that to be true, definitely log an issue! We believe that it
is best to work with the template file, and when your test is tweaked
to your liking, name it something special. 

## Test specification file ##

The second argument to take_test is the test specification
file. *Tests*  are collections of *questions*. That is all. Tests are
one of the simplest parts of the system. (For CI on CircleCI, tests
are simply expressed in YAML mardown.) You may desire to develop
custom tests for you development purposes. Custom tests may simply mix
and match stock questions. More advanced users will want to develop
custom tests with custom questions. Questions are described in the
next section. 

## Questions ##

Questions may 

1. return logical answers and require an *answer_key" ( e.g. "does x pass/fail), or 
1. return qualitative results (diagnostic outputs), e.g. "how does".

There are stock questions and you can create custom questions. 

Questions imply a known directory structure, but should remain Domain
agnostic. That is, the same test in multiple domains has the identical
directory structure. 

Questions typcially involve a premise, examples of premises:

	* There is a run
	* There is an existing run (ncores test, perfect restart tests)
	* There is a "blessed version of the code".
	
	
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

## Deficiencies, on-going, & future work

*Namelist management* As noted, the candidate specification file does
not currently specify a model run-time configuration (set of namelist
options). Run-time configurations are currently static, which means
that different domain run directories have to be specified for
different model run-time configurations (the namelists live inside 
the established run directories for each domain). 

Work has begun to integrate JSON collections of preconfigured
namelists in to the code repository so that configurations can

1. be named,
1. be generated programatically at run time,
1. evolve with the code base, 
1. be guaranteed to work and produce consistent results across versions.

Perhaps the biggest probelm this will solve is tracking a given
configurations specific namelists across the development history (and
guaranteeing this by testing the code with the namelist maintained
across versions). The flexibility of mixing domains and configurations
will tremendously simply the complexity of testing as well. The above
work will also produce tools for generating and comparing namelists
programatically. 

*Domain file management* Domain files are continually evolving with
the code. Because of their size, it is simply not feasible to keep
domain files 


# Getting Started #

## Local Machine Configuration. ##

The static, machine-dependent specifics of the candidate are separated 
from the main candidate specification file and placed into the following 
file _for each machine_:  `~/.wrf_hydro_tests_machine_spec.sh`. An 
example copy of this file is provided in the top level of this repository
but it must be moved into the correct place and editied to work properly. 


We recommend (though the sourcing is optional, the second line 
appears to put `take_test` in your path:

```
## wrf_hydro_tests
function take_test { /glade/u/home/`whoami`/some_path/wrf_hydro_tests/take_test.sh $@; }

```

# Running tests #

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


## Examples ##

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


# Customizing & Contributing
Answer-changing code development:
1. Actuall answer changing parts should be isolated to a single commit
1. Should be diagnosed (on CONUS). 
You should write diagnostic tests in the flexible framework of
wrf\_hydro\_tests as you are developing code and evaluating its
impact. All such diagnostic testing can be used by others (and
yourself) next time the same variables are being worked on.
