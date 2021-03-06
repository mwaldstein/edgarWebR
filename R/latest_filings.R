#' SEC Latest Filings
#'
#' Provides access to the latest SEC filings from
#' \href{https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent}{here}
#'
#'@param name Optional company name to limit filing results
#'@param cik Optional company cik to limit filing results
#'@param type Optional form type to limit filing results
#'@param owner How to include ownership filings. Options are
#'  \itemize{
#'    \item include (default)
#'    \item exclude
#'    \item only
#'  }
#'@param count Number of results to return
#'@param page Which page of results to return
#'
#'@return a dataframe list of recent results, ordered by descending accepted
#'        date. Includes the following columns -
#'  \itemize{
#'    \item type
#'    \item href
#'    \item company_name
#'    \item company_type
#'    \item cik
#'    \item filing_date
#'    \item accepted_date
#'    \item accession_number
#'    \item size
#'  }
#' @examples
#' \donttest{
#' try(latest_filings())
#' }
#'@export
latest_filings <- function(name = "",
                           cik = "",
                           type = "",
                           owner = "include",
                           count = 40,
                           page = 1) {
  href <- paste0(
    "https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent",
    "&CIK=", cik,
    "&type=", type,
    "&company=", name,
    "&datea=&dateb=",
    "&owner=", owner,
    "&start=", (page - 1) * count,
    "&count=", count,
    "&output=atom")
  res <- edgar_GET(href)
  doc <- xml2::read_xml(res, base_url = href, options = "HUGE")

  entries_xpath <- "entry"
  info_pieces <- list(
    "accepted_date" = "./updated",           # By inspection, updated = accepted
    "title" = "./title",
    "href" = "./link/@href",
    "type" = "./category/@term",
    "summary" = "./summary"
  )

  res <- map_xml(doc, entries_xpath, info_pieces,
                 date_format = "%Y-%m-%dT%H:%M:%S")

  m <- regexpr('[0-9]{10}', res$title)
  res$cik <- regmatches(res$title, m)
  res$company_name <- substr(res$title,
                             nchar(res$type) + 4,
                             m - 3)


  m <- regexpr('\\([^)]+\\)$', res$title)
  res$company_type <- regmatches(res$title, m)
  res$company_type <- substr(res$company_type, 2, nchar(res$company_type) - 1)
  res$title <- NULL

  m <- regexpr("Filed:</b> .{10}", res$summary)
  res$filing_date <- substr(regmatches(res$summary, m), 12, 22)

  m <- regexpr("AccNo:</b> .{20}", res$summary)
  res$accession_number <- substr(regmatches(res$summary, m), 12, 32)

  m <- regexpr('Size:<\\/b> [0-9]+ (M|K)B', res$summary)
  sizes <- regmatches(res$summary, m)
  res$size <- substr(sizes, 11, nchar(sizes))

  res$summary <- NULL

  return(res)
}
