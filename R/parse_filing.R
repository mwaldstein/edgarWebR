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
#' @param fix.errors - Try to fix document errors (e.g. missing part labels).
#'        WIP. Default: true
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
parse_filing <- function (x,
                          strip = TRUE,
                          include.raw = FALSE,
                          fix.errors = TRUE) {
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

  xpath_parts <- c(
    "/*[name() != 'div' and not(font[count(div) > 1]) and
      not(starts-with(tr[2], 'PART') or starts-with(tr[2], ' PART'))]",
    "/div[count(p|div) <= 1 and not(div[count(div) > 1]) and
      not(count(div/div/div) > 1)]",
    "/div[count(p|div) <= 1 and div[count(div) > 1]]/div/*",
    "/div[count(div) <= 1 and count(div/div/div) > 1]/div/div/div",
    "/div[count(p|div) <= 1 and div[count(div) > 1]]/div/*",
    "/div[count(p|div) > 1]/*[count(b|div) <= 1]",
    "/div[count(p|div) > 1]/*[count(b|div) > 1]/*[count(div) <= 1]",
    "/div[count(p|div) > 1]/*[count(b|div) > 1]/*[count(div)> 1]/*",
    "/p/font[count(p|div) > 1]/*",
    "/table[starts-with(tr[2], 'PART') or starts-with(tr[2], ' PART')]/tr")

  xpath_parts <- paste0(xpath_base, xpath_parts)

  nodes <- xml2::xml_find_all(doc, paste0(xpath_parts, collapse = " | "))

  if (strip) {
    nodes <- nodes[xml2::xml_name(nodes) != "hr"]
  }

  doc.parts <- data.frame(text = xml2::xml_text(nodes),
                          stringsAsFactors = FALSE)
  # strip nbspace
  doc.parts$text <- gsub("(*UCP)^\\s*|\\s*$", "", doc.parts$text, perl = TRUE)
  # QOL improvement
  doc.parts$text <- gsub("\n", " ", doc.parts$text)

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
#' @param doc.parsed - A dataframe with at minimum a 'text' column
#' @param fix.errors - Try to fix document errors (e.g. missing part labels)
#'        Default: true
#' @noRd
compute_parts <- function (doc.parsed,
                           fix.errors = TRUE) {
  return_cols <- colnames(doc.parsed)

  # when we merge in the parts/items, order gets wonky - this preserves it
  doc.parsed$original_order <- seq(nrow(doc.parsed))

  part.lines <- grepl("^part[[:space:]\u00a0]+[\\dIV]{1,3}\\b",
                      doc.parsed$text, ignore.case = TRUE) &
                (nchar(doc.parsed$text) < 34) # Hack to skip paragraphs, TOC
                                              # and page footers
  doc.parsed$part <- cumsum(part.lines)
  parts <- doc.parsed[part.lines, c("part", "text")]
  parts$text <- gsub("\u00a0", " ", parts$text)
  names(parts)[names(parts) == "text"] <- "part.name"

  item.lines <-
    grepl("^item[[:space:]\u00a0]+[[:digit:]]{1}[[:alnum:]]{0,2}([\\.:\u00a0]|$)",
          doc.parsed$text, ignore.case = TRUE) &
    !endsWith(doc.parsed$text, "(Continued)")
  doc.parsed$item <- cumsum(item.lines)

  items <- doc.parsed[item.lines, c("part", "item", "text")]
  items$text <- gsub("[\u00a0[:space:]]+", " ", items$text)
  # items$item.number <- gsub("(*UCP)^item\\s*|\\..*", "", items$text, perl = TRUE)
  names(items)[names(items) == "text"] <- "item.name"

  doc.parsed <- merge(doc.parsed, parts, all.x = TRUE)
  doc.parsed <- merge(doc.parsed, items, by = c("part", "item"), all.x = TRUE)
  doc.parsed[is.na(doc.parsed$part.name), "part.name"] <- ""
  doc.parsed[is.na(doc.parsed$item.name), "item.name"] <- ""

  doc.parsed <- doc.parsed[order(doc.parsed$original_order),
                           c(return_cols, "part.name", "item.name")]
  rownames(doc.parsed) <- NULL

  return(doc.parsed)
}
