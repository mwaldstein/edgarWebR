#' SEC Mutual Fund Search
#'
#' @param term Search term to look for funds
#'
#' @export
fund_search <- function(term) {
  uri <- paste0("https://www.sec.gov/cgi-bin/series?type=N-PX",
                "&sc=companyseries",
                "&ticker=", URLencode(term, reserved = TRUE),
                "&CIK=",
                "&Find=Search")
  data <- xml2::read_html(uri)

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

  res <- map_xml(data, entries_xpath, pieces, trim = trim_cols)

  return(res)
}
