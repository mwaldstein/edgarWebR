#' SEC Variable Insurance Search
#'
#' Provides access to the results of the SEC's Variable Insurance Product
#' search tool available
#' \href{https://www.sec.gov/edgar/searchedgar/vinsurancesearch.html}{here}
#'
#' @param term Search term to search for in a company, fund or contract name
#' @param identifier A Series, Class/Contract ID, Ticker Symbol or CIK
#' @return A dataframe of products found including the following columns -
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
#' \donttest{
#'   try(variable_insurance_search("precious metals"))
#'   try(variable_insurance_fast_search("VMFVX"))
#' }
#' @export
variable_insurance_search <- function(term) {
  series_search(company = term)
}

#' @describeIn variable_insurance_search Performs a 'Fast Search' based on an identifier
#' @export
variable_insurance_fast_search <- function(identifier) {
  series_search(cik = identifier)
}
