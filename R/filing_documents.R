#' SEC Filing Documents
#'
#' @param href URL to a SEC filing index page
#' 
#' @return A dataframe with all the documents in the filing along with their
#'    meta info
#'
#' @importFrom methods is
#'
#' @export
filing_documents <- function(href) {
  # We want to accept a pre-fetched document or possibly a sub-page node
  if (is(href, "xml_node")) {
    doc <- href
  } else {
    doc <- xml2::read_html(href)
  }

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

  res <- map_xml(doc, entries_xpath, info_pieces)

  return(res)
}
