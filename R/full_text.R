#' SEC Full-Text Search
#'
#' Provides access to the SEC fillings
#' \href{https://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp}{full-text search tool}.
#'
#'@param q Search query. For details on special formatting, see the
#' \href{https://www.sec.gov/edgar/searchedgar/edgarfulltextfaq.htm}{FAQ}.
#'@param type Type of forms to search - e.g. '10-K'
#'@param reverse_order If true, order by oldest first instead of newest first
#'@param count Number of results to return
#'@param page Which page of results to return
#'@param stemming Search by base words(default) or exactly as entered
#'@param name Company name. Cannot be combined with `cik` or `sik`.
#'@param sic Standard Industrial Classification of filer to search for. Cannot
#'        be combined with `cik` or `name`. Special options - 1: all, 0:
#'        Unspecified.
#'@param cik Company code to search. Cannot be combined with `name` or `sic`
#'@param from Start date. Must be in the form of `mm/dd/yyyy`. Must also
#'       specify `to`
#'@param to End date. Must be in the form of `mm/dd/yyyy`. Must also
#'       specify `from`
#'
#'@return A dataframe list of results including the following columns -
#'  \itemize{
#'    \item filing_date
#'    \item name
#'    \item href
#'    \item company_name
#'    \item cik
#'    \item sic
#'    \item content
#'    \item parent_href
#'    \item index_href
#'  }
#' @examples
#'\donttest{
#'## This can be very slow running
#' full_text('intel')
#'}
#'@export
full_text <- function(
    q = "*",
    type = "",
    reverse_order = FALSE,
    count = 10,
    page = 1,
    stemming = TRUE,
    name = "",
    cik = "",
    sic = "",
    from = "",
    to = "") {
  href <- paste0(
    "https://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp?",
    "search_text=", ifelse(q == "", "*", URLencode(q, reserved = TRUE)), "&",
    "sort=", ifelse(reverse_order, "ReverseDate", "Date"), "&",
    "formType=", map_form(type), "&",
    "isAdv=true&",
    "stemming=", ifelse(stemming, "true", "false"), "&",
    ifelse(page != 1,
           paste0("startDoc=", count * (page - 1) + 1, "&"), ""),
    "numResults=", count, "&",
    map_opt(name, cik, sic),
    ifelse(from != "" && to != "",
           paste0("fromDate=", from, "&",
                  "toDate=", to, "&"), ""),
    "prt=true")
  res <- httr::GET(href)
  if (res$status != "200") {
    stop(paste0("Unable to reach the SEC full text search endpoint (",
                "https://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp",
                ")"))
  }
  doc <- xml2::read_html(res, base_url = href, options = "HUGE")

  entries_xpath <- "//table/tr[@class = 'infoBorder'][preceding-sibling::*]"

  info_pieces <- list(
    filing_date = "preceding-sibling::tr[3]/td[1]",
    name = "preceding-sibling::tr[3]/td[2]/a",
    href = "preceding-sibling::tr[3]/td[2]/a/@href",
    company_name = "substring-before(
      preceding-sibling::tr[2]/td[2]/font[2]/text()[1],
      ' (CIK - '
    )",
    cik = "preceding-sibling::tr[2]/td[2]/font[2]/a[1]",
    sic = "preceding-sibling::tr[2]/td[2]/font[2]/a[2]",
    content = "preceding-sibling::tr[1]/td[2]/i",
    parent_href = "./td[2]/a[@title = 'Parent Filing']/@href",
    index_href = "./td[2]/a[@title = 'Index of Filing Documents']/@href"
  )

  trim_cols <- c('name')

  res <- map_xml(doc, entries_xpath,
                 info_pieces, trim = trim_cols,
                 date_format = "%m/%d/%Y")

  return(res)

}

map_form <- function(form) {
  if (form == "") return(1)
  form <- gsub("-", "", form)
  form <- gsub(" ", "", form)
  form <- ifelse(grepl("/", form),
                 paste0(sub("/", "", form),
                        ifelse(form == "DOS/A", "", "D")), # Yes, DOS/A has a
                                                           # different format
                 form)
  form <- paste0("Form", form)

  return(form)
}

map_opt <- function(name, cik, sic) {
  if (name != "") {
    return(paste0("queryCo=", name, "&"))
  } else if (cik != "") {
    return(paste0("queryCik=", cik, "&"))
  } else if (sic != "") {
    return(paste0("querySic=", sic, "&"))
  } else {
    return("")
  }
}
