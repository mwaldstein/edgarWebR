#' SEC Series Search
#'
#' This is the generic search for the Edgar series search - anything that
#' submits to /cgi-bin/series. It gets used by both the Variable Insurance
#' Product search and the mutual funds search
#'
#' Unless you know exactly what you are doing, you should use one of those
#' instead
#' @noRd
series_search <- function(cik = NULL,
                          company = NULL,
                          ticker = NULL,
                          type = NULL) {
  href <- series_search_href(cik, company, ticker, type)

  res <- httr::GET(href)
  if (res$status != "200") {
    stop("Unable to reach the SEC series search endpoint (https://www.sec.gov/cgi-bin/series)")
  }
  doc <- xml2::read_html(res, base_url = href, options = "HUGE")

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

#' @noRd
series_search_href <- function(cik = NULL,
                               company = NULL,
                               ticker = NULL,
                               type = NULL) {
  paste0("https://www.sec.gov/cgi-bin/series?",
         "sc=companyseries",
         ifelse(is.null(type), "",
                paste0("&type=", URLencode(type, reserved = TRUE))),
         ifelse(is.null(ticker), "",
                paste0("&ticker=", URLencode(ticker, reserved = TRUE))),
         ifelse(is.null(cik), "",
                paste0("&CIK=", URLencode(cik, reserved = TRUE))),
         ifelse(is.null(company), "",
                paste0("&company=", URLencode(company, reserved = TRUE))),
         "&Find=Search")
}
