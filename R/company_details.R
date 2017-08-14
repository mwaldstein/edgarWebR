#' SEC Company Details
#'
#' For a given company, either by ticker, CIK, or pre-fetched page, we extract 2 
#' sets of information: 
#'\describe{
#'  \item{Company Information}{Filing date, accepted date, etc.}
#'  \item{Filings}{Companies included in the filing}
#'}
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
