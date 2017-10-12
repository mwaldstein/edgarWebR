#' Parse Filing
#'
#' Given a link to filing document (e.g. the 10-K, 8-K) in HTML, process the
#' file into parts and items. This enables follow-up processing of a desired
#' section - e.g. just the Risk Factors. `item.name` and `part.name` are taken
#' directly from the document without any attempt to normalize.
#'
#' *NOTE:* This has been tested on a range of documents, but formatting
#' differences could cause failures. Please report an issue for any document
#' that isn't parsed correctly.
#'
#' @param x - URL to a filing HTML document, html text or xml_document
#' @param strip - Should non-text elements be removed? Default: true
#' @param include.raw - Include unprocessed nodes in result? Default: false
#'
#' @return a dataframe with one row per paragraph
#'   \describe{
#'     \item{part.name}{Detected name of the Part}
#'     \item{item.name}{Detected name of the Item}
#'     \item{text}{Text of the paragraph / node}
#'     \item{raw*}{Raw HTML of the node if \code{include.raw = TRUE}}
#'   }
#'
#' @examples
#' head(parse_filing(paste0('https://www.sec.gov/Archives/edgar/data/',
#'      '712515/000071251517000010/ea12312016-q3fy1710qdoc.htm')), 6)
#' @export
parse_filing <- function (x, strip = TRUE, include.raw = FALSE) {
  # TODO: This should see if we just have a text document
  if (typeof(x) == "character") {
    doc <- charToDoc(x)
  } else {
    doc <- x
  }

  xpath_base <- '//text'
  if (is.na(xml2::xml_find_first(doc, xpath_base))) {
    xpath_base <- '//body'
  }

  nodes <- xml2::xml_find_all(doc,
    paste0(xpath_base, "/*[name() != 'div'] | ",
           xpath_base, "/div[count(p|div) <= 1] | ",
           xpath_base, "/div[count(p|div) > 1]/*[count(b|font) <= 1] | ",
           xpath_base, "/div[count(p|div) > 1]/*[count(b|font) > 1]/*"))

  if (strip) {
    nodes <- nodes[xml2::xml_name(nodes) != "hr"]
  }

  doc.parts <- data.frame(text = xml2::xml_text(nodes),
                          stringsAsFactors = FALSE)
  # strip nbspace
  doc.parts$text <- gsub("(*UCP)^\\s*|\\s*$", "", doc.parts$text, perl = TRUE)

  if (include.raw) {
    doc.parts$raw <- as.character(nodes)
  }

  # Because of how most html versions are processed, each item is a paragraph.
  if (strip) {
    doc.parts <- doc.parts[doc.parts$text != "", , drop = FALSE]
  }

  doc.parts <- compute_parts(doc.parts)

  return(doc.parts)
}

#' Part/Item Processing
#'
#' @param doc - A dataframe with at minimum a 'text' column
#' @noRd
compute_parts <- function (doc) {
  return_cols <- colnames(doc)

  # when we merge in the parts/items, order gets wonky - this preserves it
  doc$original_order <- seq(nrow(doc))

  part.lines <- grepl("^part", doc$text, ignore.case = TRUE)
  doc$part <- cumsum(part.lines)
  parts <- doc[part.lines, c("part", "text")]
  parts$text <- gsub("\u00a0", " ", parts$text)
  names(parts)[names(parts) == "text"] <- "part.name"

  item.lines <- grepl("^item.{2,3}[\\.:]", doc$text, ignore.case = TRUE) &
                !endsWith(doc$text, "(Continued)")
  # We don't do this for every document as if there are no parts, we want to be
  # inclusive...
  if (nrow(parts) > 1) {
    item.lines <- item.lines & doc$part > 0
  }
  doc$item <- cumsum(item.lines)

  items <- doc[item.lines, c("part", "item", "text")]
  items$text <- gsub("\u00a0", " ", items$text)
  # items$item.number <- gsub("(*UCP)^item\\s*|\\..*", "", items$text, perl = TRUE)
  names(items)[names(items) == "text"] <- "item.name"

  doc <- merge(doc, parts, all.x = TRUE)
  doc <- merge(doc, items, by = c("part", "item"), all.x = TRUE)
  doc[is.na(doc$part.name), "part.name"] <- ""
  doc[is.na(doc$item.name), "item.name"] <- ""

  doc <- doc[order(doc$original_order), c(return_cols, "part.name", "item.name")]
  rownames(doc) <- NULL

  return(doc)
}
