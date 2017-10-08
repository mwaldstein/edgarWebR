#' SEC Filing Details
#'
#' The SEC generates a html page as an index for every filing it receives containing
#' all the meta-information about the filing. We extract 3 main types of information: 
#'\describe{
#'  \item{Filing Information}{Filing date, accepted date, etc.}
#'  \item{Documents}{All the documents included in the filing}
#'  \item{Filers}{Companies included in the filing}
#'  \item{Funds}{Funds included in the filing}
#'}
#'
#' For a company, there is typically a single filer and no funds, but many filings
#' for funds get more complicated - e.g. 400+ funds with 100's of companies
#'
#' NOTE: This can get process intensive for large fund pages. If you don't need all
#' components, try just using filing_info
#'
#' @param x URL to a SEC filing index page
#'
#' @return A list with the following components:
#'   \describe{
#'     \item{information}{A data.frame as returned by \code{\link{filing_information}}}
#'     \item{documents}{A data.frame as returned by \code{\link{filing_documents}}}
#'     \item{filers}{A data.frame as returned by \code{\link{filing_filers}}}
#'     \item{funds}{A data.frame as returned by \code{\link{filing_funds}}}
#'  }
#' @examples
#' # Typically you'd get the URL from one of the search functions
#' x <- paste0("https://www.sec.gov/Archives/edgar/data/",
#'             "712515/000071251517000063/0000712515-17-000063-index.htm")
#' filing_details(x)
#' @export
filing_details <- function(x) {
  UseMethod("filing_details")
}

#' @rdname filing_details
#' @export
filing_details.character <- function(x) {
  filing_details(charToDoc(x))
}

#' @rdname filing_details
#' @export
filing_details.xml_node <- function(x) {
  # 1 - Basic info
  info <- filing_information(x)

  # 2 - Get documents
  documents <- filing_documents(x)

  # 2 - Extract key/value pairs from he  # 3 - Get filers
  filers <- filing_filers(x)

  # 4 - Get funds
  funds <- filing_funds(x)

  return(list("information" = info,
              "documents" = documents,
              "filers" = filers,
              "funds" = funds))
}
