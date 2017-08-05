# edgarWebR

* Author/Maintainer: [Micah J Waldstein](https://micah.waldste.in)
* License: [MIT](https://opensource.org/licenses/MIT)

## Introduction
edgarWebR provides an interface to access the [SEC's EDGAR
system](https://www.sec.gov/edgar/searchedgar/webusers.htm) for company
financial filings.

EdgarWebR does *not* provide any functionality to extract financial data or
other information from filings, only the metadata and company information. For
processing of the financia data.

### Installation
Until the API stablilizes, the package is not yet available from CRAN. The best
way to install it is from github using devtools:
```{r}
# Install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("mwaldstein/edgarWebR")
```

## Related Packages
 * [XBRL](https://cran.r-project.org/web/packages/XBRL/index.html) - Low level
   extration of data from XBRL financial files
 * [finstr](https://github.com/bergant/finstr) - Process XBRL to extract data,
   combine periods, and make basic financial calulations.
 * [finreportr](https://github.com/sewardlee337/finreportr) - All in one to
   pull finnacials and information from EDGAR

