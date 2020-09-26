## Test environments
* OS X 10.13.6 (on travis-ci), R 3.6.3
* OS X 10.15.6 (on github-actions), R 4.0.2
* Ubuntu 16.04.06 (on travis-ci), R-devel 2020-09-24 r79253
* Ubuntu 16.04.03 (on travis-ci), R 3.6.1
* Ubuntu 16.04.03 (on travis-ci), R 4.0.2
* Windows i386-w64-mingw32 (on appveyor), R 3.6.2
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit (on rhub)
* Ubuntu 19.10, R 3.6.3
* Oracle Solaris 10, x86, 32 bit, 4.0.2 (on R-hub builder)

## R CMD check results
There were no ERRORs, WARNINGs.

Only NOTE refers to the Archived on 2020-01-19 due to solaris exception.

 * Solaris issue seen w/ v1.0.1 fixed
 * All examples requiring network access changed to donttest
 * All vignettes now use local caches so code may be run w/out network
 * All tests were already using cached data not requiring network access

## Downstream dependencies
There are no downstream dependencies at this point.
