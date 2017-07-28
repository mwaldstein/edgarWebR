#' SEC Company Filings
#'
#' @param ticker either a stock ticker or CIK number
#' @param ownership boolean for inclusion of company change filings
#' @param type Type of filing to fetch
#' @param before yyyymmdd fromat of latest filing to fetch
#' @param count Number of filings to fetch per page
#' @param page Which page of results to return
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
    "date" = "./content/filing-date",
    "url" = "./content/filing-href",
    "type" = "./content/filing-type",
    "film_number" = "./content/film-number",
    "form_name" = "./content/form-name",
    "items_desc" = "./content/items-desc",
    "size" = "./content/size"
    )

  res <- map_xml(data, entries_xpath, info_pieces)

  return(res)
}
