# Change Log

All changes will be documented in this file with most recent changes at the top

__WARNING:__ edgarWebR is still in active development and new vesions will
bread old code.

## v0.0.3 - *Under Development*

### Package
 * [vignettes] changed Introduction to use purrr for clearer code

### Internal
 * Added caches to ignore files

## v0.0.2 - The "XPath is is powerful" release
**_UNSTABLE_ - Function calls and returns likely to change without warning**

### Features
 * [filings] `filing_information` provides general filing information
 * [filings] `filing_funds` gives all funds associated with a filing
 * [filings] `filing_filers` gives all filers associated with a filing
 * [filings] `filing_details` returns the information, funds, filers and
   documents for a filing

### Package
 * [vignettes] We now have a basic introductory vignette
 * [tests] initial testes created

### Internal
 * [map_xml] map_xml now parses date/time columns into POSIXlt dates
 * [browse_edgar] escape text fields

## v0.0.1 - Initial Release
**_UNSTABLE_ - Function calls and returns likely to change without warning**
