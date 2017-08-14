% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/company_details.R
\name{company_details}
\alias{company_details}
\title{SEC Company Details}
\usage{
company_details(x, ownership = FALSE, type = "", before = "",
  count = 40, page = 1)
}
\arguments{
\item{x}{either a stock ticker, CIK number, or XML document for a company page}

\item{ownership}{boolean for inclusion of company change filings}

\item{type}{Type of filing to fetch. NOTE: due to the way the SEC EDGAR system 
works, it is actually is a 'starts-with' search, so for instance specifying
'type = "10-K" will return "10-K/A" and "10-K405" filings as well. To ensure
you only get the type you want, best practice would be to filter the results.}

\item{before}{yyyymmdd fromat of latest filing to fetch}

\item{count}{Number of filings to fetch per page. Valid options are 10, 20, 40,
80, or 100. Other values will result in the closest count.}

\item{page}{Which page of results to return.}
}
\value{
A dataframe with all the parsed meta-info on the filing
}
\description{
The SEC generates a html page as an index for every filing it receives containing
all the metainformation about the filing. We extract 3 main types of information: 
\describe{
 \item{Company Information}{Filing date, accepted date, etc.}
 \item{Filings}{Companies included in the filing}
}
}
\details{
For a company, there is typically a single filer and no funds, but many filings
for funds get more complicated - e.g. 400+ funds with 100's of companies

NOTE: This can get process intensive for large fund pages. If you don't need all
components, try just usning filing_info
}
\examples{
company_details("AAPL")
}