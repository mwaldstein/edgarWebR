#' SEC CIK Search
#'
#' Provides access to the SEC CIK search tool from
#' \href{https://www.sec.gov/edgar/searchedgar/cik.htm}{here}
#'
#' @param company Search term to search for CIK
#' @return A dataframe with one row per company with 
#'        Includes the following columns -
#'  \itemize{
#'    \item cik
#'    \item company_href
#'    \item company_name
#'  }
#' @examples
#' cik_search("cloudera")
#' @export
cik_search <- function(company) {
  href <- paste0("https://www.sec.gov/cgi-bin/cik_lookup",
                "?company=", URLencode(company, reserved = TRUE))
  res <- httr::GET(href)
  doc <- xml2::read_html(res, base_url = href)

  entries_xpath <- "//pre/a[starts-with(@href,'browse-edgar')]"

  pieces <- list(
    cik = ".",
    company_href = "@href",
    company_name = "following-sibling::text()[1]"
  )

  trim_cols <- c("company_name")

  res <- map_xml(doc, entries_xpath, pieces, trim = trim_cols)

  return(res)
}
