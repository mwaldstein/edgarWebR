is_url <- function(x) {
  grepl("^(http|ftp)s?://", x)
}

get_doc <- function(x, clean = F) {
  if (typeof(x) == "character") {
    if (is_url(x)) {
      res <- httr::GET(x)
      doc <- xml2::read_html(res, base_url = x)
    } else {
      doc <- xml2::read_html(x)
    }
  } else {
    doc <- x
  }

  if (clean) {
    doc <- clean_doc(doc)
  }

  doc
}

charToDoc <- function(x) {
  if (is_url(x)) {
    res <- httr::GET(x)
    xml2::read_html(res, base_url = x)
  } else {
    xml2::read_html(x)
  }
}

charToText <- function(x) {
  if (is_url(x)) {
    res <- httr::GET(x)
    return(httr::content(res, encoding = "UTF-8"))
  } else {
    return(x)
  }
}

# strips difficult to handle html bits we don't really care about
# @param x text of an html document
clean_html <- function(x) {
  x <- gsub("&nbsp;", " ", x, ignore.case = T)
  x <- gsub("<br>", " ", x, ignore.case = T)
  x <- gsub("<br/>", " ", x, ignore.case = T)
  x
}

# removes br from the doc since we don't really care about display, replacing
# with spaces
clean_doc <- function(doc) {
  replacement <- xml2::xml_find_first(xml2::read_xml("<p> </p>"),
                                      "/p/text()")
  xml2::xml_replace(xml2::xml_find_all(doc, "//br"), replacement)

  doc
}
