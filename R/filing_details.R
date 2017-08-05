#' SEC Filing Details
#'
#' The SEC generates a html page as an index for every filing it receives containing
#' all the metainformation about the filing. We extract 3 main types of information: 
#'\itemize{
#'  \item Filing Information - Filing date, accepted date, etc.
#'  \item Documents - All the documents included in the filing
#'  \item Filers - Companies included in the filing
#'  \item Funds - Funds included in the filing
#'}
#'
#' For a company, there is typically a single filer and no funds, but many filings
#' for funds get more complicated - e.g. 400+ funds with 100's of companies
#'
#' NOTE: This can get process intensive for large fund pages. If you don't need all
#' components, try just usning filing_info
#'
#' @param href URL to a SEC filing index page
#' 
#' @return A dataframe with all the parsed meta-info on the filing
#'
#' @importFrom methods is
#'
#' @export
filing_details <- function(href) {
  # We want to accept a pre-fetched document or possibly a sub-page node
  if (is(href, "xml_node")) {
    doc <- href
  } else {
    doc <- xml2::read_html(href)
  }

  # 1 - Basic info
  info <- filing_information(doc)

  # 2 - Get documents
  documents <- filing_documents(doc)

  # 2 - Extract key/value pairs from he  # 3 - Get filers
  filers <- filing_filers(doc)

  # 4 - Get funds
  funds <- filing_funds(doc)

  return(list("information" = info,
              "documents" = documents,
              "filers" = filers,
              "funds" = funds))
}
