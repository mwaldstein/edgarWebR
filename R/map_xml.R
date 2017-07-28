#' Map XML Entries
#'
#' Extracts a dataframe from an xml document.
#'
#' @param doc An XML document
#' @param entries_xpath an xpath locator for all starting points
#' @param parts a list in the form column name = xpath locator
#' @param trim a list of columns that need to have whitespace trimmed
#'
#' @return A dataframe with one row per entry and columns from parts
#'
#' @importFrom xml2 xml_text xml_find_first xml_ns_strip xml_find_all xml_url url_absolute
map_xml <- function(doc, entries_xpath, parts, trim = c()) {
  xml_ns_strip(doc)
  entries <- xml_find_all(doc, entries_xpath)

  res <- sapply(parts, function(path) {
           sapply(entries, function(entry) {
             xml_text(xml_find_first(entry, path))
           })
         })

  # TODO: this implies there is a bug in the preceeding maping that oversimplifies
  if (length(entries) == 1) {
    res <- t(res)
  }

  res <- data.frame(res, stringsAsFactors = FALSE)

  for (col in trim) {
    res[[col]] <- trimws(res[[col]])
  }

  link_cols <- colnames(res)[grepl("href$", colnames(res))]
  for (ref in link_cols) {
    res[[ref]] <- ifelse(is.na(res[[ref]]), NA, url_absolute(res[[ref]], xml_url(doc)))
  }

  return(res)
}
