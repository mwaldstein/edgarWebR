#' SEC Company Details
#'
#' The SEC generates a html page as an index for every filing it receives containing
#' all the metainformation about the filing. We extract 2 types of information: 
#'\describe{
#'  \item{Company Information}{Filing date, accepted date, etc.}
#'  \item{Filings}{Companies included in the filing}
#'}
#'
#' For a company, there is typically a single filer and no funds, but many filings
#' for funds get more complicated - e.g. 400+ funds with 100's of companies
#'
#' NOTE: This can get process intensive for large fund pages. If you don't need all
#' components, try just usning filing_info
#'
#' @inheritParams company_filings
#' 
#' @return A list with the following components
#'  \describe{
#'    \item{information}{data.frame as returned by \code{\link{company_information}}}
#'    \item{filings}{data.frame as returned by \code{\link{company_filings}}}
#'  }
#' @importFrom methods is
#' @examples
#' company_details("AAPL")
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
