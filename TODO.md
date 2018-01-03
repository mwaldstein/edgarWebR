# Todo

A bit of a roadmap/todo

## Features
 * support this thing
   - https://www.sec.gov/cgi-bin/own-disp?CIK=0000051143&action=getissuer
 * [filing_filers] - parse out filer type/role
 * Alias company\_ functions to filer\_ to cover non-company filers better
 * company href given CIK
 * Return master filing href where possible
 * Parse filing page numbers to enable better manual section describing and TOC
   parsing/usage.

## Bugs
 * There are not enough "exclusions" in xpath for parse_filing leading to
   parents and children getting selected. E.g.
   https://www.sec.gov/Archives/edgar/data/7084/000000708409000051/adm10kfy09.htm

## Internal
 * Passing lints
 * Improve makefile http://kbroman.org/minimal_make/,
   https://github.com/ComputationalProteomicsUnit/maker
 * tests for util.R and get company_information to 100% coverage
 * downstream checks

## Package
 * Vignette pulling XBL files using finstr
