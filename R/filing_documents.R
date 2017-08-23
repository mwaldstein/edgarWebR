#' SEC Filing Documents
#'
#' If you know you're going to want all the details of a filing, including documents
#' funds and filers, look at `filing_details`
#'
#' Information returned:
#' \itemize{
#'  \item seq
#'  \item description
#'  \item document
#'  \item href
#'  \item type
#'  \item size
#' }
#'
#' @param x URL or xml_document for a SEC filing index page
#' 
#' @return A dataframe with all the documents in the filing along with their
#'    meta info
#'
#' @examples
#' # Typically you'd get the URL from one of the search functions
#' x <- paste0("https://www.sec.gov/Archives/edgar/data/",
#'             "712515/000071251517000063/0000712515-17-000063-index.htm")
#' filing_documents(x)
#' @export
filing_documents <- function(x) {
  UseMethod("filing_documents")
}

#' @rdname filing_documents
#' @export
filing_documents.character <- function(x) {
  filing_documents(charToDoc(x))
}

#' @rdname filing_documents
#' @export
filing_documents.xml_node <- function(x) {
  entries_xpath <- paste0(
    "//table[@summary='Document Format Files']/tr[not(descendant::th)]|",
    "//table[@summary='Data Files']/tr[not(descendant::th)]")

  info_pieces <- list(
    "seq" = "td[1]",
    "description" = "td[2]",
    "document" = "td[3]/a/text()",
    "href" = "td[3]/a/@href",
    "type" = "td[4]",
    "size" = "td[5]"
    )

  res <- map_xml(x, entries_xpath, info_pieces, integers = c("seq", "size"))

  return(res)
}
