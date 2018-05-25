#' SEC Mutual Fund Search
#'
#' Provides access to the results of the SEC's Mutual fund search tool
#' available
#' \href{https://www.sec.gov/edgar/searchedgar/mutualsearch.html}{here}
#'
#' NOTE: This is really a specific version of the Variable Insurance search
#' tool.
#'
#' @param term Search term to search for in a fund name
#' @param identifier A Series, Class/Contract ID, Ticker Symbol or CIK
#' @return A dataframe of funds found including the following columns -
#'   \itemize{
#'     \item class_id
#'     \item class_filings_href
#'     \item class_name
#'     \item class_ticker
#'     \item series_id
#'     \item series_filings_href
#'     \item series_name
#'     \item series_funds_href
#'     \item cik
#'     \item cik_name
#'     \item cik_filings_href
#'     \item cik_funds_href
#'   }
#' @examples
#' fund_search("precious metals")
#' fund_fast_search("VMFVX")
#' @export
fund_search <- function(term) {
  series_search(company = term, type = "N-PX")
}

#' @describeIn fund_search Performs a 'Fast Search' based on a fund identifier
#' @export
fund_fast_search <- function(identifier) {
  if (grepl("^\\d+$", identifier)) {
    series_search(cik = identifier, type = "N-PX")
  } else {
    series_search(ticker = identifier, type = "N-PX")
  }
}
