# edgarWebR

[![Travis-CI Build Status](https://travis-ci.org/mwaldstein/edgarWebR.svg?branch=master)](https://travis-ci.org/mwaldstein/edgarWebR)
[![codecov.io](https://codecov.io/github/mwaldstein/edgarWebR/coverage.svg?branch=master)](https://codecov.io/github/mwaldstein/edgarWebR?branch=master)


* Author/Maintainer: [Micah J Waldstein](https://micah.waldste.in)
* License: [MIT](https://opensource.org/licenses/MIT)

## Introduction
edgarWebR provides an interface to access the [SEC's EDGAR
system](https://www.sec.gov/edgar/searchedgar/webusers.htm) for company
financial filings.

EdgarWebR does *not* provide any functionality to extract financial data or
other information from filings, only the metadata and company information. For
processing of the financia data.

## EDGAR Tools

The EDGAR System provides a number of [tools](https://www.sec.gov/edgar/searchedgar/webusers.htm)
for filing and entity lookup and examination. edgarWebR will eventually support
all of the provided tools, but for now it is focused on covering company and
fund search and resultant filings.

*Search Interfaces:*

| Tool                          | URL                                                             | edgarWebR function(s) |
|-------------------------------|-----------------------------------------------------------------|-----------------------|
| Company                       | https://www.sec.gov/edgar/searchedgar/companysearch.html        | `company_information` |
| Recent Filings                | https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent      | N/A |
| Full Text                     | http://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp | N/A |
| Adv. Search                   | https://www.sec.gov/cgi-bin/srch-edgar                          | N/A |
| Fund Disclosures              | https://www.sec.gov/edgar/searchedgar/prospectus.htm            | N/A |
| Fund Voting Records           | https://www.sec.gov/edgar/searchedgar/n-px.htm                  | N/A |
| Fund Search                   | https://www.sec.gov/edgar/searchedgar/mutualsearch.html         | `fund_search` |
| Var. Insurance Products       | https://www.sec.gov/edgar/searchedgar/vinsurancesearch.html     | N/A |
| Confidential treatment orders | https://www.sec.gov/edgar/searchedgar/ctorders.htm              | N/A |
| Effectiveness notices         | https://www.sec.gov/cgi-bin/browse-edgar?action=geteffect       | N/A |
| CIK                           | https://www.sec.gov/edgar/searchedgar/cik.htm                   | N/A |
| Daily Filings                 | https://www.sec.gov/edgar/searchedgar/currentevents.htm         | N/A |
| Correspondence                | https://www.sec.gov/answers/edgarletters.htm                    | N/A |

### Installation
Until the API stablilizes, the package is not yet available from CRAN. The best
way to install it is from github using devtools:
```{r}
# Install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("mwaldstein/edgarWebR")
```

## Related Packages
 * [XBRL](https://CRAN.R-project.org/package=XBRL) - Low level
   extration of data from XBRL financial files
 * [finstr](https://github.com/bergant/finstr) - Process XBRL to extract data,
   combine periods, and make basic financial calulations.
 * [finreportr](https://github.com/sewardlee337/finreportr) - All in one to
   pull finnacials and information from EDGAR

Code of Conduct
---------------
Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to abide by
its terms. Report violations to (micah@waldste.in).
