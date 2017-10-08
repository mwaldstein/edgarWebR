# Todo

A bit of a roadmap/todo

## Features
 * support this thing
   - https://www.sec.gov/cgi-bin/own-disp?CIK=0000051143&action=getissuer
 * [filing_filers] - parse out filer type/role
 * Alias company\_ functions to filer\_ to cover non-company filers better
 * company href given CIK
 * Return master filing href where possible
 * parse filing document header

## Bugs

## Internal
 * Passing lints
 * Improve makefile http://kbroman.org/minimal_make/,
   https://github.com/ComputationalProteomicsUnit/maker
 * Cache for vignettes - longest part of build at the moment
 * Have travis/appveyor run tests without cache for assurances
 * tests for util.R and get company_information to 100% coverage
 * downstream checks
 * add no-vignettes options as a cache alternative

## Package
 * Vignette pulling XBL files using finstr
