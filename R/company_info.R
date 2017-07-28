#' SEC Company Info
#'
#' Fetches basic information on a given company from the SEC site
#'
#' @param ticker Either a stock symbol (for the 10,000 largest companies) or CIK
#'   code
#'
#' @return a dataframe with all SEC company information
#'
#' @export
company_info <- function(ticker) {
  data <- browse_edgar(ticker)

  entry_xpath <- "company-info"

  info_pieces <- list(
    "name" = "conformed-name",
    "cik" = "cik",
    "fiscal_year_end" = "fiscal-year-end",
    "sic" = "assigned-sic",
    "sic_description" = "assigned-sic-desc",
    "state_location" = "state-location",
    "state_incorporation" = "state-of-incorporation",
    "mailing_city" = "//address[@type='mailing']/city",
    "mailing_state" = "//address[@type='mailing']/state",
    "mailing_zip" = "//address[@type='mailing']/zip",
    "mailing_street" = "//address[@type='mailing']/street1",
    "business_city" = "//address[@type='business']/city",
    "business_state" = "//address[@type='business']/state",
    "business_zip" = "//address[@type='business']/zip",
    "business_street" = "//address[@type='business']/street1",
    "business_phone" = "//address[@type='business']/phone"
    )

  res <- map_xml(data, entry_xpath, info_pieces)
  return(res)
}
