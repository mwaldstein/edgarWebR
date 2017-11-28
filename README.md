
<!-- README.md is generated from README.Rmd. Please edit that file -->
edgarWebR
=========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/edgarWebR)](https://cran.r-project.org/package=edgarWebR) [![Travis-CI Build Status](https://travis-ci.org/mwaldstein/edgarWebR.svg?branch=master)](https://travis-ci.org/mwaldstein/edgarWebR) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mwaldstein/edgarWebR?branch=master&svg=true)](https://ci.appveyor.com/project/mwaldstein/edgarWebR) [![codecov.io](https://codecov.io/github/mwaldstein/edgarWebR/coverage.svg?branch=master)](https://codecov.io/github/mwaldstein/edgarWebR?branch=master)

-   Author/Maintainer: [Micah J Waldstein](https://micah.waldste.in)
-   License: [MIT](https://opensource.org/licenses/MIT)

Introduction
------------

edgarWebR provides an interface to access the [SEC's EDGAR system](https://www.sec.gov/edgar/searchedgar/webusers.htm) for company financial filings.

EdgarWebR does *not* provide any functionality to extract financial data or other information from filings, only the metadata and company information. For processing of the financia data.

EDGAR Tools
-----------

The EDGAR System provides a number of [tools](https://www.sec.gov/edgar/searchedgar/webusers.htm) for filing and entity lookup and examination. edgarWebR will eventually support all of the provided tools, but for now it is focused on covering company and fund search and resultant filings.

*Search Interfaces:*

<table>
<colgroup>
<col width="26%" />
<col width="54%" />
<col width="19%" />
</colgroup>
<thead>
<tr class="header">
<th>Tool</th>
<th>URL</th>
<th>edgarWebR function(s)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Company</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/companysearch.html" class="uri">https://www.sec.gov/edgar/searchedgar/companysearch.html</a></td>
<td><code>company_information()</code>, <code>company_details()</code>, <code>company_filings()</code></td>
</tr>
<tr class="even">
<td>Recent Filings</td>
<td><a href="https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent" class="uri">https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent</a></td>
<td><code>latest_filings()</code></td>
</tr>
<tr class="odd">
<td>Full Text</td>
<td><a href="http://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp" class="uri">http://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp</a></td>
<td><code>full_text()</code></td>
</tr>
<tr class="even">
<td>Header Search</td>
<td><a href="https://www.sec.gov/cgi-bin/srch-edgar" class="uri">https://www.sec.gov/cgi-bin/srch-edgar</a></td>
<td>N/A</td>
</tr>
<tr class="odd">
<td>Fund Disclosures</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/prospectus.htm" class="uri">https://www.sec.gov/edgar/searchedgar/prospectus.htm</a></td>
<td>N/A</td>
</tr>
<tr class="even">
<td>Fund Voting Records</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/n-px.htm" class="uri">https://www.sec.gov/edgar/searchedgar/n-px.htm</a></td>
<td>N/A</td>
</tr>
<tr class="odd">
<td>Fund Search</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/mutualsearch.html" class="uri">https://www.sec.gov/edgar/searchedgar/mutualsearch.html</a></td>
<td><code>fund_search()</code></td>
</tr>
<tr class="even">
<td>Var. Insurance Products</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/vinsurancesearch.html" class="uri">https://www.sec.gov/edgar/searchedgar/vinsurancesearch.html</a></td>
<td>N/A</td>
</tr>
<tr class="odd">
<td>Confidential treatment orders</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/ctorders.htm" class="uri">https://www.sec.gov/edgar/searchedgar/ctorders.htm</a></td>
<td>N/A</td>
</tr>
<tr class="even">
<td>Effectiveness notices</td>
<td><a href="https://www.sec.gov/cgi-bin/browse-edgar?action=geteffect" class="uri">https://www.sec.gov/cgi-bin/browse-edgar?action=geteffect</a></td>
<td>N/A</td>
</tr>
<tr class="odd">
<td>CIK</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/cik.htm" class="uri">https://www.sec.gov/edgar/searchedgar/cik.htm</a></td>
<td>N/A</td>
</tr>
<tr class="even">
<td>Daily Filings</td>
<td><a href="https://www.sec.gov/edgar/searchedgar/currentevents.htm" class="uri">https://www.sec.gov/edgar/searchedgar/currentevents.htm</a></td>
<td>N/A</td>
</tr>
<tr class="odd">
<td>Correspondence</td>
<td><a href="https://www.sec.gov/answers/edgarletters.htm" class="uri">https://www.sec.gov/answers/edgarletters.htm</a></td>
<td>N/A</td>
</tr>
</tbody>
</table>

Once a filing is found via any of the above, there are a number of functions to process the result -

-   `filing_documents()`
-   `filing_filers()`
-   `filing_funds()`
-   `filing_information()`
-   `filing_details()` - returns all 4 of the filing components in a list.

### Parsing Tools

While edgarWebR is primarily focused on providing an interface to the online SEC tools, there are a few activities for handling filing documents for which no current tools exist.

-   `parse_submission()` - takes a full submission SGML document and parses out compontent documents. Most of the time, the documents of interest in a particular submission will be online and accessible via `filing_documents()` - this function is to unpack the raw submission to get all the doucments. You may also find it more efficient if you're regularly downloading all of the files in a given submission.
-   `parse_filing()` - Takes a HTML narrative filing and annotates each paragraph with item and part numbers.

### Installation

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

Example
-------

``` r
company_filings("AAPL", type = "10-K", count = 10)
#>        accession_number act file_number filing_date accepted_date
#> 1  0000320193-17-000070  34   001-36743  2017-11-03    2017-11-03
#> 2  0001628280-16-020309  34   001-36743  2016-10-26    2016-10-26
#>                                                                                                href
#> 1  https://www.sec.gov/Archives/edgar/data/320193/000032019317000070/0000320193-17-000070-index.htm
#> 2  https://www.sec.gov/Archives/edgar/data/320193/000162828016020309/0001628280-16-020309-index.htm
#>      type film_number
#> 1    10-K   171174673
#> 2    10-K   161953070
#>                                                 form_name description
#> 1  Annual report [Section 13 and 15(d), not S-K Item 405]        <NA>
#> 2  Annual report [Section 13 and 15(d), not S-K Item 405]        <NA>
#>     size
#> 1  14 MB
#> 2  13 MB
#>  [ reached getOption("max.print") -- omitted 8 rows ]
```

Related Packages
----------------

-   [XBRL](https://CRAN.R-project.org/package=XBRL) - Low level extration of data from XBRL financial files
-   [finstr](https://github.com/bergant/finstr) - Process XBRL to extract data, combine periods, and make basic financial calulations.
-   [finreportr](https://github.com/sewardlee337/finreportr) - All in one to pull finnacials and information from EDGAR

Code of Conduct
---------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms. Report violations to (<micah@waldste.in>).
