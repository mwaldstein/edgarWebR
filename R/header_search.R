#' SEC Header Search
#'
#' Seaches filing headers going back to 1994 excluding the most recent day
#' using the interface \href{here}{https://www.sec.gov/cgi-bin/srch-edgar}.
#'
#' @param q The search string. Documentation
#'   \href{here}{https://www.sec.gov/edgar/searchedgar/search_help.htm}
#' @param from Start year (default: 1994)
#' @param to End year (default: Current year)
#' @param page Which results page to return (default: 1)
#' @return A dataframe of funds found including the following columns -
#'   \itemize{
#'     \item company_name
#'     \item filing_href
#'     \item form
#'     \item filing_date
#'     \item size
#'   }
#' @examples
#'\donttest{
#'## This can be very slow running
#' header_search("company-name = Apple")
#'}
#' @export
header_search <- function(q, page = 1, from = 1994, to = 2017) {
  href <- paste0("https://www.sec.gov/cgi-bin/srch-edgar?",
                "text=", URLencode(q, reserved = TRUE),
                "&first=", from,
                "&last=", to)
  if (page > 1) {
    href <- paste0(href,
                   "&start=", 80 * (page - 1) + 1,
                   "&count=80")
  }
  res <- httr::GET(href)
  doc <- xml2::read_html(res, base_url = href)

  entries_xpath <- "body/div/table/tr[position() > 1]"

  pieces <- list(
    company_name = "td[2]/a",
    filing_href = "td[2]/a/@href",
    form = "td[4]",
    filing_date = "td[5]",
    size = "td[6]"
  )

  res <- map_xml(doc,
                 entries_xpath,
                 pieces,
                 date_format = "%m/%d/%Y")

  return(res)
}
