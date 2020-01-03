# edgarWebR 1.0.1

## Bugfixes
 * `parse_text_filing()` correctly parses filings that have spaces in
     separating lines. (Fixes #4)
 * `parse_text_filing()` correctly removes and splits on '<PAGE>' dividers,
     including when there is no page number. (fixes #6)
 * Initial fix for #11 where some documents with especially deep structures
     would error in the parsing phase.
 * Check for errors connecting to SEC servers and stop on failures.

## Documentation
 * Elaborate the parsing vignette to better explain the files processed by
   `parse_filing()` and `parse_submission()`
 * Document output of `parse_submission()`
 * Document how the SEC Company 'Fast Search' works and how edgarWebR
   implements it. (addresses #7)

## Internal
 * Add missing pkgdown dev dependency
 * Add lintr dev dependency
 * Update tests w/ current data

# edgarWebR 1.0.0 - "Everything in its place"

## Features
 * `sic_codes` a dataset for sic codes from [US Department of
   Labor](https://www.osha.gov/pls/imis/sic_manual.html)
 * `parse_submission()` has options for skipping collection of all content or
   just binary content
 * Added utility functions `submission_index_href()`, `submission_href()`, and
   `submission_file_href()` for creating links to filings and their components.
 * Added `cik_search()` to lookup CIK codes for companies.
 * Added `current_events()` to access recent filings by form type
 * Added `company_search()`
 * Added `variable_insurance_search()` and `variable_insurance_fast_search()`
 * Added `fund_fast_search()`
 * Added `effectiveness()`

## Bugfixes
 * `parse_filing()` properly processes recent AIG & Costco filings
 * `parse_filing()` properly processes ADM filings for fy08 & fy09
 * `parse_filing()` now fails gracefully given a unparsable filing
 * `parse_filing()` properly handles extraneous '<PAGE>' tags from ~08/09 filings
   such as
   [ADP](https://www.sec.gov/Archives/edgar/data/8670/000120677409001642/adp_10k.htm)
 * `parse_filing()` handles more edge-cases and has similar word counts to plain
     document.
 * `parse_submission()` handles large files successfully using temp files.
 * `parse_submission()` handles submissions with single files correctly.
 * `parse_submission()` documented properly.
 * `full_text()` escapes the search query properly.

## Internal
 * Testing now requires tokenizers for testing if parsing adds words (it often
   does...)
 * Moved to testdata for parse_* functions rather than http cache
 * Made wordcount comparison in test_parse_filing far more restrictive (good
     thing!)
 * Tried to make TravisCI work, but still not great...
 * Added series_search to cover the main work for fund and variable insurance
     searches.

# edgarWebR 0.3.1 - "Oh yeah, data changes"
## Bugfixes
 * `full_text` no longer tests example as it often is long-running
 * `header_search` no longer tests example as it often is long-running
 * Vignette 'parsing' now always fetches the same filing to avoid issues with
   newer filings changing the output

# edgarWebR 0.3.0 - "Going all the way back"

## Features
 * `full_text` provides access to the full-text filing search interface.
 * `latest_filings` provides access to the latest SEC filings.
 * `parse_text_filing` parses text-only 10-* filings.
 * `parse_filing` detects when a filing is HTML wrapped plain text and uses
   `parse_text_filing` when appropriate.
 * `header_search` provides access to search filing headers back to 1994

## Bugfixes
 * `parse_filing` now treats `<br>` as a space avoiding words separated only
   by a line return getting concatenated. (Fixes #2)
 * `parse_filing` now tries to detect and remove TOC itemss/parts to avoid
   duplicate entries

## Internal
 * `map_xml` processes href's out of javascript links
 * `map_xml` add parameter for date format
 * linting setup to run in CI

# edgarWebR 0.2.1 - "Thanks Testers"

Many thanks to everyone providing feedback, particularly Günter Leitold for
rigorously testing the `parse_filing` funcion.

## Bugfixes
 * Parser covers a wider range of document formats for 10-K's.
 * `filing_documents` correctly provides the href for the document not the
   iXBRL viewer when present.

## Internal
 * Limited testing of `parse_filing` on CRAN.

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
