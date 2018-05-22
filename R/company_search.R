#' SEC Company Search
#'
#' Provides access to the SEC Company Name Search from
#' \href{https://www.sec.gov/edgar/searchedgar/companysearch.html}{here}
#' using a company's formal name rather than its common name.
#'
#' @param x Name of company to search or file number
#' @param match (default: 'start') Either 'start' or 'contains' for where in
#'   the company name to search
#' @param file_number (default: FALSE) if set to TRUE, x is treated as a file
#'   number
#' @param state (default: '') Limit to a specific state of registration using
#'   2-letter state abbreviations.   Special values:
#'   \describe{
#'     \item{X1}{The United States}
#'     \item{A0}{Alberta, Canada}
#'     \item{A1}{British Columbia, Canada}
#'     \item{A2}{Manitoba, Canada}
#'     \item{A3}{New Brunswick, Canada}
#'     \item{A4}{Newfoundland, Canada}
#'     \item{A5}{Nova Scotia, Canada}
#'     \item{A6}{Ontario, Canada}
#'     \item{A7}{Prince Edward Island, Canada}
#'     \item{A8}{Quebec, Canada}
#'     \item{A9}{Saskatchewan, Canada}
#'     \item{B0}{Yukon, Canada}
#'   }
#' @param country 2-character country code. The mapping is non-obvious, so
#'   unfortunately the best way to find it is to examine the company search page.
#' @param sic SIC Code
#' @param ownership boolean for inclusion of company change filings
#' @param type Limit to companiew with a given filing type - e.g. 'N-PX'
#' @param count Number of filings to fetch per page. Valid options are 10, 20,
#'   40, 80, or 100. Other values will result in the closest count.
#' @param page Which page of results to return.
#' @return A dataframe of companies
#'   \itemize{
#'     \item cik
#'     \item company_href
#'     \item name
#'     \item location
#'     \item location_href
#'     \item formerly
#'     \item sic
#'     \item sic_description
#'     \item sic_href
#'   }
#' @examples
#' company_search("Intel")
#' @export
company_search <- function(x,
                           match = "start",
                           file_number = FALSE,
                           state = "",
                           country = "",
                           sic = "",
                           ownership = FALSE,
                           type = "",
                           count = 40,
                           page = 1) {
  if (ownership == TRUE) ownership <- "include"
  if (ownership == FALSE) ownership <- "exclude"
  if (ownership == "") ownership <- "exclude"
  href <- paste0(
    "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany",
    ifelse(file_number,
           paste0("&company=&filenum=", x),
           paste0("&company=", URLencode(x, reserved = TRUE))),
    ifelse(match == "start", "&match=", paste0("&match=", match)),
    ifelse(state == "", "&State=", paste0("&State=", toupper(state))),
    ifelse(country == "", "&Country=", paste0("&Country=", toupper(country))),
    ifelse(sic == "", "&SIC=", paste0("&SIC=", sic)),
    "&myowner=", ownership,
    ifelse(type == "", "", paste0("&type=", type)),
    ifelse(count != 40 || page != 1, paste0("&count=", count), ""),
    ifelse(page != 1, paste0("&start=", count * (page - 1)), ""),
    "&output=atom")

  res <- httr::GET(href)
  doc <- xml2::read_xml(res, base_url = href)
  xml2::xml_ns_strip(doc)

 # Check if there is only one result and we\ ve gone to a company page
  if (!is.na(xml2::xml_find_first(doc, "/feed/company-info"))) {
    info <- company_information(doc)
    return(info)
  }

  entries_xpath <- "/feed/entry/content"

  info_pieces <- list(
    name = "company-info/name",
    cik = "company-info/cik",
    fiscal_year_end = "company-info/fiscal-year-end",
    company_href = "link/@href",
    sic = "company-info/sic",
    state_location = "company-info/state",
    state_incorporation = "company-info/state-of-incorporation",
    formerly = "company-info/formerly-names",
    mailing_city = "company-info/addresses/address[@type='mailing']/city",
    mailing_state = "company-info/addresses/address[@type='mailing']/state",
    mailing_zip = "company-info/addresses/address[@type='mailing']/zip",
    mailing_street1 = "company-info/addresses/address[@type='mailing']/street1",
    mailing_street2 = "company-info/addresses/address[@type='mailing']/street2",
    business_city = "company-info/addresses/address[@type='business']/city",
    business_state = "company-info/addresses/address[@type='business']/state",
    business_zip = "company-info/addresses/address[@type='business']/zip",
    business_street1 = "company-info/addresses/address[@type='business']/street1",
    business_street2 = "company-info/addresses/address[@type='business']/street2",
    business_phone = "company-info/addresses/address[@type='business']/phone"
  )

  res <- map_xml(doc, entries_xpath, info_pieces)

  return(res)
}
