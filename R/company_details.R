#' SEC Company Details
#'
#' The SEC generates a html page as an index for every filing it receives containing
#' all the metainformation about the filing. We extract 3 main types of information: 
#'\itemize{
#'  \item Company Information - Filing date, accepted date, etc.
#'  \item Filings - Companies included in the filing
#'}
#'
#' For a company, there is typically a single filer and no funds, but many filings
#' for funds get more complicated - e.g. 400+ funds with 100's of companies
#'
#' NOTE: This can get process intensive for large fund pages. If you don't need all
#' components, try just usning filing_info
#'
#' @param x either a stock ticker, CIK number, or XML document for a company page
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
#' @return A dataframe with all the parsed meta-info on the filing
#'
#' @importFrom methods is
#'
#' @export
company_details <- function(x, 
                         ownership = FALSE, 
                         type = "",
                         before="", 
                         count = 40,
                         page = 1) {
  # We want to accept a pre-fetched document or possibly a sub-page node
  doc <- if (is(x, "xml_node")) { x } else {
           browse_edgar(x,
                        ownership = ownership,
                        type = type,
                        before = before,
                        count = count,
                        page = page)
  }

  # 1 - Basic info
  info <- company_information(doc)

  # 2 - Get documents
  filings <- company_filings(doc)

  return(list("information" = info,
              "filings" = filings))
}
