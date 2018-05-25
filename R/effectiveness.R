#' SEC Notice of Effectiveness
#'
#' Returns the current Noice of Effectiveness from the most recently completed
#' business day from
#' \href{https://www.sec.gov/cgi-bin/browse-edgar?action=geteffect}{here}
#'
#' You can also see the same filings going further back by using
#' `latest_filings()` specifying the type = "EFFECT"
#'
#' @return a data.frame with each row as a submission with the following
#'   columns:
#'   \describe{
#'     \item{registration_number}{}
#'     \item{file_href}{}
#'     \item{registrant}{}
#'     \item{registrant_href}{}
#'     \item{filing_date}{}
#'     \item{effective_date}{}
#'     \item{division}{}
#'     \item{type}{}
#'  }
#' @examples
#' effectiveness()
#' @export
effectiveness <- function() {
  href <- "https://www.sec.gov/cgi-bin/browse-edgar?action=geteffect"
  res <- httr::GET(href)
  doc <- xml2::read_html(res, base_url = href)

  entries_xpath <- "//a[contains(@href, 'filenum=')]"
  info_pieces <- list(
    registration_number = ".",
    file_href = "@href",
    registrant = "../../td[3]/a/text()",
    registrant_href = "../../td[3]/a/@href",
    filing_date_str = "../../td[4]/text()",
    effective_date_str = "../../td[5]/text()",
    division = "../../preceding-sibling::tr[count(td[@colspan=3]) = 1][1]/td[2]",
    type = "../../preceding-sibling::tr[count(td[@colspan=5]) = 1][1]/td[1]"
  )

  res <- map_xml(doc, entries_xpath, info_pieces)

  # We don't need the qualifiers
  res$type <- sub(" Statements", "", res$type, fixed = T)
  res$division <- sub("Division of ", "", res$division, fixed = T)

  #
  res[res$type == "Securities Act Registration", "effective_date"] <-
    as.POSIXct(res[res$type == "Securities Act Registration",
                   "effective_date_str"],
               format = "%B %d, %Y %I:%M %p",
               tz = "America/New_York")
  res[res$type != "Securities Act Registration", "effective_date"] <-
    as.POSIXct(res[res$type != "Securities Act Registration",
                   "effective_date_str"],
               format = "%B %d, %Y",
               tz = "America/New_York")
  res[res$type != "Securities Act Registration", "filing_date"] <-
    as.POSIXct(res[res$type != "Securities Act Registration",
                   "filing_date_str"],
               format = "%B %d, %Y",
               tz = "America/New_York")

  res$filing_date_str <- NULL
  res$effective_date_str <- NULL

  res
}
