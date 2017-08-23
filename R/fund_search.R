#' SEC Mutual Fund Search
#'
#' @param term Search term to look for funds
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
#' @export
fund_search <- function(term) {
  href <- paste0("https://www.sec.gov/cgi-bin/series?type=N-PX",
                "&sc=companyseries",
                "&ticker=", URLencode(term, reserved = TRUE),
                "&CIK=",
                "&Find=Search")
  res <- httr::GET(href)
  doc <- xml2::read_html(res, base_url = href)

  entries_xpath <- "//a[starts-with(.,'C')]"

  pieces <- list(
    class_id = ".",
    class_filings_href = "@href",
    class_name = "following::td[1]",
    class_ticker = "following::td[2]",
    series_id = "preceding::td[@colspan=2][1]/a",
    series_filings_href = "preceding::td[@colspan=2][1]/a/@href",
    series_name = "preceding::td[@colspan=2][1]/following-sibling::td[1]",
    series_funds_href = "preceding::td[@colspan=2][1]/following-sibling::td[1]/a",
    cik = "preceding::td[@colspan=3][1]/a",
    cik_name = "preceding::td[@colspan=3][1]/following-sibling::td[1]/a",
    cik_filings_href = "preceding::td[@colspan=3][1]/a/@href",
    cik_funds_href = "preceding::td[@colspan=3][1]/following-sibling::td[1]/a/@href"
  )

  trim_cols <- c("class_ticker")

  res <- map_xml(doc, entries_xpath, pieces, trim = trim_cols)

  return(res)
}
