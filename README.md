
<!-- README.md is generated from README.Rmd. Please edit that file -->

# edgarWebR

## NOTES:

  - A bug was encountered on the Solaris CRAN checks which led to the
    package being removed from CRAN. I’m working on a fix, but not
    having access to the platform makes testing challenging.

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/edgarWebR)](https://cran.r-project.org/package=edgarWebR)
![R-CMD-check](https://github.com/mwaldstein/edgarWebR/workflows/R-CMD-check/badge.svg)
[![codecov.io](https://codecov.io/github/mwaldstein/edgarWebR/coverage.svg?branch=master)](https://codecov.io/github/mwaldstein/edgarWebR?branch=master)

  - Author/Maintainer: [Micah J Waldstein](https://micah.waldste.in)
  - License: [MIT](https://opensource.org/licenses/MIT)

## Introduction

edgarWebR provides an interface to access the [SEC’s EDGAR
system](https://www.sec.gov/edgar/search-and-access) for company
financial filings.

edgarWebR does *not* provide any functionality to extract financial data
or other information from filings, only the metadata and company
information. For processing of the financial data.

## EDGAR Tools

The EDGAR System provides a number of
[tools](https://www.sec.gov/edgar/search-and-access) for filing and
entity lookup and examination. As of v1.0, edgarWebR supports all public
search and browse interfaces.

*Search Interfaces:*

| Tool                          | URL                                                                | edgarWebR function(s)                                                                                                    |
| ----------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Company                       | <https://www.sec.gov/edgar/searchedgar/companysearch.html>         | `company_search()`, `company_information()`, `company_details()`, `company_filings()`                                    |
| Recent Filings                | <https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent>       | `latest_filings()`                                                                                                       |
| Full Text                     | <https://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp> | `full_text()`                                                                                                            |
| Header Search                 | <https://www.sec.gov/cgi-bin/srch-edgar>                           | `header_search()`                                                                                                        |
| Fund Disclosures              | <https://www.sec.gov/edgar/searchedgar/prospectus.htm>             | Use `company_search()` and specify the ‘type’ parameter as 485                                                           |
| Fund Voting Records           | <https://www.sec.gov/edgar/searchedgar/n-px.htm>                   | Use `company_search()` and specify the ‘type’ parameter as ‘N-PX’                                                        |
| Fund Search                   | <https://www.sec.gov/edgar/searchedgar/mutualsearch.html>          | `fund_search()`, `fund_fast_search()`                                                                                    |
| Var. Insurance Products       | <https://www.sec.gov/edgar/searchedgar/vinsurancesearch.html>      | `variable_insurance_search()`, `variable_insurance_fast_search()`                                                        |
| Confidential treatment orders | <https://www.sec.gov/edgar/searchedgar/ctorders.htm>               | Use `header_search()`, `company_search()`, `latest_filings()`, or `full_text()` and use form types ‘CT ORDER’            |
| Effectiveness notices         | <https://www.sec.gov/cgi-bin/browse-edgar?action=geteffect>        | `effectiveness()`                                                                                                        |
| CIK                           | <https://www.sec.gov/edgar/searchedgar/cik.htm>                    | `cik_search()`                                                                                                           |
| Daily Filings                 | <https://www.sec.gov/edgar/searchedgar/currentevents.htm>          | `current_events()`                                                                                                       |
| Correspondence                | <https://www.sec.gov/answers/edgarletters.htm>                     | Use `header_search()`, `company_search()`, `latest_filings()`, or `full_text()` and use form types ‘upload’ or ‘corresp’ |

Once a filing is found via any of the above, there are a number of
functions to process the result -

  - `filing_documents()`
  - `filing_filers()`
  - `filing_funds()`
  - `filing_information()`
  - `filing_details()` - returns all 4 of the filing components in a
    list.

### Parsing Tools

While edgarWebR is primarily focused on providing an interface to the
online SEC tools, there are a few activities for handling filing
documents for which no current tools exist.

  - `parse_submission()` - takes a full submission SGML document and
    parses out component documents. Most of the time, the documents of
    interest in a particular submission will be online and accessible
    via `filing_documents()` - this function is to unpack the raw
    submission to get all the documents. You may also find it more
    efficient if you’re regularly downloading all of the files in a
    given submission.
  - `parse_filing()` - Takes a HTML narrative filing and annotates each
    paragraph with item and part numbers.

### Data Sets

There is one dataset provided with edgarWebR - `sic_codes`, providing a
catalog of SIC codes and their hierarchy.

### URL Tools

There are also a number of utility functions to help construct useful
URL’s once you have a company CIK, submission accession number or
specific file.

  - `company_href()` for linking to the company page
  - `submission_index_href()` and its family of related functions for
    linking to a specific submission and file.

## Installation

edgarWebR is available from CRAN, so can be simply installed via

``` r
install.packages("edgarWebR")
```

To install the development version,

``` r
# Install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("mwaldstein/edgarWebR")
```

## Example

``` r
company_filings("AAPL", type = "10-K", count = 10)
#>        accession_number act file_number filing_date accepted_date
#> 1  0000320193-19-000119  34   001-36743  2019-10-31    2019-10-30
#> 2  0000320193-18-000145  34   001-36743  2018-11-05    2018-11-05
#> 3  0000320193-17-000070  34   001-36743  2017-11-03    2017-11-03
#> 4  0001628280-16-020309  34   001-36743  2016-10-26    2016-10-26
#> 5  0001193125-15-356351  34   001-36743  2015-10-28    2015-10-28
#> 6  0001193125-14-383437  34   000-10030  2014-10-27    2014-10-27
#> 7  0001193125-13-416534  34   000-10030  2013-10-30    2013-10-29
#> 8  0001193125-12-444068  34   000-10030  2012-10-31    2012-10-31
#> 9  0001193125-11-282113  34   000-10030  2011-10-26    2011-10-26
#> 10 0001193125-10-238044  34   000-10030  2010-10-27    2010-10-27
#>                                                                                                href
#> 1  https://www.sec.gov/Archives/edgar/data/320193/000032019319000119/0000320193-19-000119-index.htm
#> 2  https://www.sec.gov/Archives/edgar/data/320193/000032019318000145/0000320193-18-000145-index.htm
#> 3  https://www.sec.gov/Archives/edgar/data/320193/000032019317000070/0000320193-17-000070-index.htm
#> 4  https://www.sec.gov/Archives/edgar/data/320193/000162828016020309/0001628280-16-020309-index.htm
#> 5  https://www.sec.gov/Archives/edgar/data/320193/000119312515356351/0001193125-15-356351-index.htm
#> 6  https://www.sec.gov/Archives/edgar/data/320193/000119312514383437/0001193125-14-383437-index.htm
#> 7  https://www.sec.gov/Archives/edgar/data/320193/000119312513416534/0001193125-13-416534-index.htm
#> 8  https://www.sec.gov/Archives/edgar/data/320193/000119312512444068/0001193125-12-444068-index.htm
#> 9  https://www.sec.gov/Archives/edgar/data/320193/000119312511282113/0001193125-11-282113-index.htm
#> 10 https://www.sec.gov/Archives/edgar/data/320193/000119312510238044/0001193125-10-238044-index.htm
#>    type film_number                                              form_name
#> 1  10-K   191181423 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 2  10-K   181158788 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 3  10-K   171174673 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 4  10-K   161953070 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 5  10-K   151180619 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 6  10-K   141175110 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 7  10-K   131177575 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 8  10-K   121171452 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 9  10-K   111159350 Annual report [Section 13 and 15(d), not S-K Item 405]
#> 10 10-K   101145250 Annual report [Section 13 and 15(d), not S-K Item 405]
#>    description  size
#> 1         <NA> 12 MB
#> 2         <NA> 12 MB
#> 3         <NA> 14 MB
#> 4         <NA> 13 MB
#> 5         <NA>  9 MB
#> 6         <NA> 12 MB
#> 7         <NA> 11 MB
#> 8         <NA>  9 MB
#> 9         <NA>  9 MB
#> 10        <NA> 13 MB
```

## Related Packages

  - [XBRL](https://CRAN.R-project.org/package=XBRL) - Low level
    extration of data from XBRL financial files
  - [finstr](https://github.com/bergant/finstr) - Process XBRL to
    extract data, combine periods, and make basic financial calulations.
  - [finreportr](https://github.com/sewardlee337/finreportr) - All in
    one to pull finnacials and information from EDGAR

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](https://mwaldstein.github.io/edgarWebR/CONDUCT.html). By
participating in this project you agree to abide by its terms. Report
violations to (<micah@waldste.in>).
