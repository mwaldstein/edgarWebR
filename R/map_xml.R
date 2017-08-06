#' Map XML Entries
#'
#' Extracts a dataframe from an xml document.
#'
#' @param doc An XML document
#' @param entries_xpath an xpath locator for all starting points
#' @param parts a list in the form column name = xpath locator
#' @param trim a list of columns that need to have whitespace trimmed
#'
#' @keywords internal
#'
#' @return A dataframe with one row per entry and columns from parts
map_xml <- function(doc, entries_xpath, parts, trim = c()) {
  xml2::xml_ns_strip(doc)
  entries <- xml2::xml_find_all(doc, entries_xpath)

  # TODO: a lot of optimization should be possible here...
  res <- sapply(parts, function(path) {
           sapply(entries, function(entry) {
             node <- xml2::xml_find_first(entry, path)
             if (typeof(node) == "character") {
               return(node)
             } else {
               return(xml2::xml_text(node))
             }
           })
         })

  # TODO: this implies there is a bug in the preceeding maping that
  # oversimplifies
  if (length(entries) == 1) {
    res <- t(res)
  }

  res <- data.frame(res, stringsAsFactors = FALSE)

  for (col in trim) {
    res[[col]] <- trimws(res[[col]])
  }

  link_cols <- colnames(res)[grepl("href$", colnames(res))]
  for (ref in link_cols) {
    res[[ref]] <- ifelse(is.na(res[[ref]]), NA,
                         xml2::url_absolute(res[[ref]], xml2::xml_url(doc)))

    # We need to do this because the rss gives http url's - this saves the
    # redirect
    res[[ref]] <- gsub("http:", "https:", res[[ref]])
  }

  date_cols <- colnames(res)[grepl("date$", colnames(res))]
  for (ref in date_cols) {
    res[[ref]] <- as.POSIXct(res[[ref]])
  }

  return(res)
}
