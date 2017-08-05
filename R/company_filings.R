#' SEC Company Filings
#'
#' @param ticker either a stock ticker or CIK number
#' @param ownership boolean for inclusion of company change filings
#' @param type Type of filing to fetch. NOTE: due to the way the SEC EDGAR system 
#'     works, it is actually is a 'starts-with' search, so for instance specifying
#'     'type = "10-K" will return "10-K/A" and "10-K405" filings as well. To ensure
#'     you only get the type you want, best practice would be to filter the results.
#' @param before yyyymmdd fromat of latest filing to fetch
#' @param count Number of filings to fetch per page. Valid options are 10, 20, 40,
#'     80, or 100. Other values will result in the closest count.
#' @param page Which page of results to return.
#'
#' @return A dataframe of company filings
#'
#' @export
company_filings <- function(ticker,
                         ownership = FALSE,
                         type = "",
                         before="",
                         count = 40,
                         page = 1) {
  data <- browse_edgar(ticker,
                       ownership = ownership,
                       type = type,
                       before = before,
                       count = count,
                       page = page)

  entries_xpath <- "entry"

  info_pieces <- list(
    "accession" = "./content/accession-nunber",
    "act" = "./content/act",
    "file_number" = "./content/file-number",
    "filing_date" = "./content/filing-date",
    "href" = "./content/filing-href",
    "type" = "./content/filing-type",
    "film_number" = "./content/film-number",
    "form_name" = "./content/form-name",
    "items_desc" = "./content/items-desc",
    "size" = "./content/size"
    )

  res <- map_xml(data, entries_xpath, info_pieces)

  return(res)
}
