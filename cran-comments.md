## FIXING CRAN ERRORS

Existing v0.1.0 on CRAN produces test errors due to instability in remote
source data. Re-aigned with tests with source, longer term solution will be to
adjust test strategy to use stable submissions.

## Test environments
* OS X 10.11.6 (on travis-ci), R 3.4.1
* Ubuntu 14.04 (on travis-ci), R 3.4.1
* Windows i386-w64-mingw32 (on appveyor), R 3.4.1 Patched (2017-08-11 r73088)

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

* checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Micah J Waldstein <micah@waldste.in>’

Days since last update: 5

## Downstream dependencies
There are no downstream dependencies at this point.
