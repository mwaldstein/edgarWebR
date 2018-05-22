#' SEC Current Events
#'
#' Provides access to the SEC Current Events search tool from
#' \href{https://www.sec.gov/edgar/searchedgar/currentevents.htm}{here}
#'
#' @param day (0-5) Day to search for current forms. e.g. '2' returns forms
#'   from 2 business days ago.
#' @param form Form to return filings (e.g. '10-K')
#' @return A dataframe with one row per company with
#'        Includes the following columns -
#'  \itemize{
#'    \item cik
#'    \item type
#'    \item href
#'    \item company_name
#'    \item company_href
#'    \item filing_date
#'  }
#' @examples
#' current_events(0, "10-K")
#' @export
current_events <- function(day, form) {
  href <- paste0("https://www.sec.gov/cgi-bin/current",
                 "?q1=", day,
                 "&q2=0",       # This is the form box which q3 overrides
                 "&q3=", URLencode(form, reserved = TRUE))
  res <- httr::GET(href)
  doc <- xml2::read_html(res, base_url = href)

  # Because this is preformatted content, using typical xml finding 
  # doc <- httr::content(res, "text")
  # doc_lines <- strsplit(doc, "[\r\n]+")

  entries_xpath <- "//pre/a[starts-with(@href,'/Archives/edgar/data')]"

  pieces <- list(
    type = ".",
    href = "@href",
    cik = "following-sibling::a[1]",
    company_href = "following-sibling::a[1]/@href",
    company_name = "following-sibling::text()[2]",
    date_str = "preceding-sibling::text()[1]"
  )

  trim_cols <- c("company_name")

  res <- edgarWebR:::map_xml(doc, entries_xpath, pieces,
                             trim = trim_cols)

  res$filing_date <- as.POSIXct(trimws(gsub(".*\n", "", res$date_str)),
                         format = "%m-%d-%Y")
  res$date_str <- NULL
  res$company_name <- trimws(gsub("\n.*", "", res$company_name))

  return(res)
}
