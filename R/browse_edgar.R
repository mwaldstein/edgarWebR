#' Browse Edgar Web
#'
#' Attempts to access Edgar Web's browse page for a given company
#'
#' @param ticker either a stock ticker or CIK number
#' @param ownership boolean for inclusion of company change filings
#' @param type Type of filing to fetch
#' @param before yyyymmdd format of latest filing to fetch
#' @param count Number of filings to fetch per page
#' @param page Which page of results to return
#'
#' @keywords internal
#'
#' @importFrom utils URLencode
#'
#' @return A xml document
browse_edgar <- function(ticker,
                         ownership = FALSE,
                         type = "",
                         before="",
                         count = 40,
                         page = 1) {
  href <- paste0("https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany",
                "&CIK=", URLencode(ticker, reserved=TRUE),
                "&owner=", ifelse(ownership, "include", "exclude"),
                "&type=", URLencode(type, reserved=TRUE),
                "&dateb=", before,
                "&start=", (page - 1) * count,
                "&count=", count,
                "&output=atom")
  data <- try(xml2::read_xml(href), silent = TRUE)

  suppressWarnings({
  if (class(data) == "try-error") {
    stop("No matching company found.");
  }
  })

  return(data)
}
