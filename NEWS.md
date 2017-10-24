# edgarWebR 0.2.0.9000 - **DEVELOPMENT**

## Bugfixes
 * Parser covers a wider range of document formats for 10-K's.
 * `filing_documents` correctly provides the href for the document not the
   iXBRL viewer when present.

# edgarWebR 0.2.0 - "Parse all the things"

## Features

### Parse Filings
New functionality in `parse_filing` to annotate a filing with part and item
identifiers. This enables easy extraction of risks or management discussions.

*NOTE:* While tested on a range of documents, due to the high variation in
filing formats, it is likely not to work on every document. Please open an
issue if errors are encountered.

### Parse Submission
New function `parse_submission` extracts documents from the full submission file.
This is needed for older submissions and accessing documents that are not extracted
individually online.

## Internal
 * Incorporated [httptest](https://github.com/nealrichardson/httptest) for cached testing. Altered most functions to use [httr](https://cran.r-project.org/package=httr) for remote calls to support this test method.
 * New Makefile targets to support cached testing -
   - `make test` - uses cached responses
   - `make test-nocache` - makes all remote calls
   - `make test-buildcache` - runs tests, caching remote requests.
   - `make test-cleancache` - deletes the test cache

# edgarWebR 0.1.1 - "Whoops 1"

## Bugfixes
 * Removed a test for the "changed_date" field in filing information as the
   source test document removed the field. Permanent fix will be to use a
   a more stable data source for testing.

# edgarWebR 0.1.0 - "Hello World"

First CRAN release of edgarWebR. At this point, function parameters, return
colums and general shape of data will not change without a deprecation process
and due warning.

## Features

### Searching

 * The `company_information()`, `company_details()`, and `company_filings()`
   for searching and getting information for a given company or filer.
 * `fund_search()` searches for mutual funds and fund families.

### Filings
 * `filing_information()`, `filing_documents()`, `filing_filers()`, and
   `filing_funds()` extract information sections from a particular filing.
 * `filing_details()` extracts all 4 components from a particular filing.

# edgarWebR 0.0.3 - "Now Getting it Ready"
**_UNSTABLE_ - Function calls and returns likely to change without warning**

## Features
 * All methods which took a URL as a parameter now accept either a href or 
   pre-loaded xml document. This facilitates loading a filing from a local
   file, fetching the filing separately for customized parsing, and testing.
 * Some column names have shifted to better align to overall naming scheme

## Package
 * [vignettes] changed Introduction to use purrr for clearer code

## Internal
 * Added caches and markdown folders to ignore files
 * Made map_xml handle parsing integers
 * Added live_test to Makefile
 * Way more tests
 * coverage target added to makefile

# edgarWebR 0.0.2 - "XPath is is powerful"
**_UNSTABLE_ - Function calls and returns likely to change without warning**

## Features
 * [filings] `filing_information` provides general filing information
 * [filings] `filing_funds` gives all funds associated with a filing
 * [filings] `filing_filers` gives all filers associated with a filing
 * [filings] `filing_details` returns the information, funds, filers and
   documents for a filing

## Package
 * [vignettes] We now have a basic introductory vignette
 * [tests] initial testes created

## Internal
 * [map_xml] map_xml now parses date/time columns into POSIXlt dates
 * [browse_edgar] escape text fields

# edgarWebR 0.0.1 - Initial Release
**_UNSTABLE_ - Function calls and returns likely to change without warning**
