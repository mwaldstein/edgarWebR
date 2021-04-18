#' Parse Filing
#'
#' Given a link to filing document (e.g. the 10-K, 8-K) in HTML, process the
#' file into parts and items. This enables follow-up processing of a desired
#' section - e.g. just the Risk Factors. `item.name` and `part.name` are taken
#' directly from the document without any attempt to normalize.
#'
#' \strong{NOTE:} This has been tested on a range of documents, but formatting
#' differences could cause failures. Please report an issue for any document
#' that isn't parsed correctly.
#'
#' \strong{FURTHER NOTE:} Not all filings are well formed - missing headings, bad
#' spacing, etc. These can all throw the parsing off!
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
#' \donttest{
#' try(head(parse_filing(paste0('https://www.sec.gov/Archives/edgar/data/',
#'      '712515/000071251517000010/ea12312016-q3fy1710qdoc.htm')), 6))
#' }
#' @export
parse_filing <- function(x,
                         strip = TRUE,
                         include.raw = FALSE,
                         fix.errors = TRUE) {
  doc <- get_doc(x, clean = T)

  xpath_base <- '//text'
  if (is.na(xml2::xml_find_first(doc, xpath_base))) {
    xpath_base <- '//body'
  }

  # detect html-wrapped plain text filings
  nodes <- xml2::xml_find_all(doc, paste0(xpath_base, "/*"))
  tag_names <- unique(xml2::xml_name(nodes))
  if (!(FALSE %in% (tag_names %in% c("title", "pre", "hr")))) {
    return(parse_text_filing(xml2::xml_text(doc),
                             strip = strip,
                             include.raw = include.raw))
  }

  doc.parts <- build_parts(doc, xpath_base, include.raw = include.raw)

  if (strip) {
    doc.parts <- doc.parts[doc.parts$name != "hr", ]
  }

  # strip nbspace
  doc.parts$text <- gsub("(*UCP)^\\s*|\\s*$", "", doc.parts$text, perl = TRUE)
  if (include.raw) {
    doc.parts$raw <- gsub("\U00A0", "&#160;", doc.parts$raw)
  }
  # QOL improvement
  doc.parts$text <- gsub("\n", " ", doc.parts$text)

  # Because of how most html versions are processed, each item is a paragraph.
  if (strip) {
    doc.parts <- doc.parts[doc.parts$text != "", , drop = FALSE]
  }

  doc.parts$name <- NULL

  doc.parts <- compute_parts(doc.parts)

  return(doc.parts)
}

#' Parse Text Filing
#'
#' Given a link to a filing document (e.g. the 10-K, 8-K) in TXT, process the
#' file into parts and items. This enables follow-up processing of a desired
#' section - e.g. just the Risk Factors. `item.name` and `part.name` are taken
#' directly from the document without any attempt to normalize.
#'
#' \strong{NOTE:} This has been tested on a range of documents, but formatting
#' differences could cause failures. Please report an issue for any document
#' that isn't parsed correctly.
#'
#' \strong{FURTHER NOTE:} Not all filings are well formed - missing headings, bad
#' spacing, etc. These can all throw the parsing off!
#'
#' @param x - URL to a filing text document or actual text
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
#' \donttest{
#' head(parse_text_filing(
#'   "https://www.sec.gov/Archives/edgar/data/37996/000003799602000015/v7.txt"
#' ))
#' }
#' @export
parse_text_filing <- function(x,
                              strip = TRUE,
                              include.raw = FALSE,
                              fix.errors = TRUE) {
  doc <- charToText(x)

  # Make sure page markers are isolated
  doc <- gsub("([^\\n])\\n<PAGE>", "\\1\n\n<PAGE>", doc)
  doc <- gsub("(<PAGE>[^\n]*)\\n([^\n])", "\\1\n\n\\2", doc)


  # Clean empty lines
  doc <- gsub("\\n +\\n", "\n\n", doc)
  parts <- data.frame(text = trimws(unlist(strsplit(doc, "\n{2,}"))),
                      stringsAsFactors = F)
  if (strip) {
    # Remove SGML front/end matter
    parts$text[1] <- sub("^.*<TEXT>[ \n]*", "", parts$text[1])
    parts$text[nrow(parts)] <- sub("</TEXT>.*$", "", parts$text[nrow(parts)])

    parts <- parts[
      !grepl("^<PAGE>[[:blank:]]*[[:digit:]]*[[:blank:]]*$", parts$text),
      , drop = FALSE]

    parts <- parts[parts$text != "", , drop = FALSE]
  }
  if (include.raw) {
    parts$raw <- parts$text
  }

  parts <- compute_parts(parts)
  return(parts)
}

#' Manually identify the node paths
#' @noRd
build_parts <- function(doc, xpath_base,
                        include.raw = F,
                        include.path = F) {
  nodes <- doc_nodes(doc, xpath_base)

  doc.parts <- data.frame(text = xml2::xml_text(nodes),
                          name = xml2::xml_name(nodes),
                          stringsAsFactors = FALSE)

  if (include.raw) {
    doc.parts$raw <- as.character(nodes)
  }
  if (include.path) {
    doc.parts$path <- xml2::xml_path(nodes)
  }
  return(doc.parts)
}

#' @noRd
doc_nodes <- function(doc, xpath_base) {
  # There be dragons here...
  # Basically this extacts all the individual paragraphs from a document in one
  # go. This is so bad on so many levels... but the inherent messiness of the
  # filings prevents anything much more robust.
  # xpath_parts <- c( "//div[count(.//div) < 1]")
  xpath_parts <- c(
    "/*[name() != 'div' and
        not(font[count(div) > 1]) and
        not(starts-with(tr[2], 'PART') or
            starts-with(tr[2], ' PART'))]",
    "/div[count(p|div) <= 1 and
          not(div[count(div) > 1]) and
          not(count(div/div/div) > 1) and
          count(div/font) = 0]",
    "/div[count(p|div) <= 1 and
          count(div/div) > 1 and
          count(div/div/div) <= 1]/div/*",
    "/div[count(p|div) <= 1 and
          count(div/div) > 1 and
          count(div/div/div) >= 1]/div/div/*[count(div) < 1]",
    "/div[count(div) <= 1 and
          count(div/div/div) > 1 and
          count(div/div/div/div/div) <= 1 and
          count(div/div/div/*) < 1]/div/div/div[count(div) < 1]",
    "/div[count(div/div/div/div/*) > 1]/div/div/div/div/*",
    "/div[count(div/div/div/div/*) > 1]/div/div/div/div[count(*) < 1]",
    "/div[count(div/div/div/*) >= 1 and
          count(div/div/div/div/*) < 1]/div/div/div/*[name() != 'font' and
                                                      name() != 'table']",
    "/div/div/div/div/font",
    "/div[count(p|div) <= 1 and
          count(div/div) > 1 and
          count(div/div/div) <= 1]/div/*",
    "/div[./ul and ./div]/div/font",
    "/div[./ul and ./div]/ul/li",
    "/div[count(p|div) > 1]/*[count(b|div) <= 1 and count(div/div) < 1]",
    "/div[count(p|div) > 1]/div[count(b|div) <= 1 and count(div/div) > 1]",
    "/div[count(p|div) > 1]/*[count(b|div) > 1]/*[count(div) <= 1]",
    "/div[count(p|div) > 1]/*[count(b|div) > 1]/div[count(div) = 1]/div[count(div) = 1]/div",
    "/div[count(p|div) > 1]/*[count(b|div) > 1]/*[count(div)> 1]/*[count(div) < 1]",
    "/div[count(div) = 1]/div[count(div) = 1]/div[count(p)> 1]/*",
    "/div[count(div) = 1]/div[count(font) = count(*)]/font",
    "/div[count(div) = 1]/div/font[count(*) = 0]",
    "/div[count(div) = 1]/div/div/table",
    "/div/font[count(*) = 0]",
    "/div/pre",
    "/p/font[count(p|div) > 1]/*",
    "/div/table[count(./tr) = count(./tr/td)]/tr/td/div",
    "/table[starts-with(tr[2], 'PART') or starts-with(tr[2], ' PART')]/tr",

    # This deals with poor nesting in EDGARizer
    "/div/div/text()",
    # Fix for early versions of EDGARizer
    "/div/div/div/text()[1]",
    "/div/div/div/text()[2]",
    # Catch 'Table of Contents' for Webfilings
    "/div/div/a",

    # All multi-column tables
    "/table[count(./tr) < count(./tr/td)]",
    "/div/table[count(./tr) < count(./tr/td)]",
    "/div/div/table[count(./tr) < count(./tr/td)]",
    "/div/div/div/table[count(./tr) < count(./tr/td)]",
    "/div/div/div/div/table[count(./tr) < count(./tr/td)]",
    # "bare" text blocks
    # Only impacts a few filings for huge performance hit.
    # "/text()[normalize-space() != '']"

    # Nasty deeply nested table from
    # https://www.sec.gov/Archives/edgar/data/1065648/000106564809000009/form_10k.htm
    "/div/div/div/div/div/div/div/div/div/div/table"
    )


  ###
  # Paragraph identification method
  ###
  para.nodes <- c("font", paste0("h", seq(5)), "a", "b", "i", "u", "sup")
  non.para <- c("div", "dl", "li", "hr", "ol", "p", "ul", "table")
  depths <- c("./", "./*/", "./*/*/")
  depths <- c("./", "./*/")
  # depths <- c("./")
  # bases <- c("//*")
  bases <- c("/*", "/*/*", "/*/*/*", "/*/*/*/*", "/*/*/*/*/*")
  xpath_parts_2 <- c(
    #
    #paste0("//", c("div", "font", paste0("h", seq(5)), "p"), "[", paste0(c(
    # perhaps move to not(/p) and not(/*/p) and not (/*/*/p) instead of adding
    paste0(
      bases,
      "[",
      paste0(c(
        paste0("not(",
               apply(expand.grid(depths, non.para), 1, function(x) {
                       paste0(x, collapse = "")
               }),
               ")"),
      # paste0(c(
      #   paste0(paste0("count(",
      #                 apply(expand.grid(depths, para.nodes), 1, function(x) {
      #                         paste0(x, collapse = "") }),
      #                 ")",
      #                 collapse = " + "),
      #          " = ",
      #          paste0("count(", depths, "*)", collapse = " + ")),

      # paste0("count(.//*[",
      #        paste0("local-name() != '", para.nodes, "'", collapse = " and "),
      #      "]) = 0"),
      # paste0("local-name(ancestor::*[1]) != '", para.nodes, "'"),
      "local-name() != 'title'",
      "local-name() != 'td'"),
      collapse = " and "),
      "]"),
    # Unroll tables-as-formatting
    "//table[.//tr[count(td) > 1]]",
    "//table[not(.//tr[count(td) > 1])]/tr/td/*"
    )

  xpath_parts <- paste0(xpath_base, xpath_parts)

  nodes <- xml2::xml_find_all(doc, paste0(xpath_parts, collapse = " | "))

  # ensures no nested nodes
  paths <- xml2::xml_path(nodes)
  with.parent <- sapply(paths,
                        function(path) {
                          sum(startsWith(path, paths)) > 1
                        })
  nodes[!with.parent]
}

#' Walks into a nodlist, returning nested children
#' @noRd
reduce_nodes <- function(nodes) {
    xml2::xml_find_first(nodes,
      "descendant-or-self::*[
        (count(*) + count(text()[normalize-space() != ''])) != 1 or
        local-name() = 'table' or
        (count(*) = 0 and count(text()[normalize-space() != ''])) >= 1)]")
}

#' Part/Item Processing
#'
#' @param doc.parsed - A dataframe with at minimum a 'text' column
#' @param fix.errors - Try to fix document errors (e.g. missing part labels)
#'        Default: true
#' @noRd
compute_parts <- function(doc.parsed,
                          fix.errors = TRUE) {
  return_cols <- colnames(doc.parsed)

  if (nrow(doc.parsed) == 0) {
    result <- replicate(length(return_cols) + 2, character(), simplify = F)
    names(result) <- c(return_cols, "item.name", "part.name")

    return(as.data.frame(result))
  }

  # when we merge in the parts/items, order gets wonky - this preserves it
  doc.parsed$original_order <- seq(nrow(doc.parsed))

  part.lines <- grepl("^part[[:space:]\u00a0]+[\\dIV]{1,3}\\b",
                      doc.parsed$text, ignore.case = TRUE) &
                !grepl("^part[[:space:]\u00a0]+[\\dIV]{1,3}[[:space:]\u00a0]+\\d+$",
                      doc.parsed$text, ignore.case = TRUE) &
                (nchar(doc.parsed$text) < 100) # Hack to skip paragraphs, TOC
                                              # and page footers
  doc.parsed$part <- cumsum(part.lines)
  parts <- doc.parsed[part.lines, c("part", "text", "original_order")]
  parts$text <- gsub("\u00a0", " ", parts$text)
  parts$text <- gsub("\\.$", "", parts$text)
  names(parts)[names(parts) == "text"] <- "part.name"

  # for some situations, we'll have caught all items - this pulls the items
  parts$part.name <-
    gsub("[\\.[:space:\u00a0]*item[[:space:]\u00a0]+[[:digit:]]{1}[[:alnum:]]{0,2}.*$", "",
         parts$part.name,
         ignore.case = T)

  # \u2014 is em-dash
  item.lines <-
    grepl("^(part [IV]{1,3}. )?item[[:space:]\u00a0]+[[:digit:]]{1}[[:alnum:]]{0,2}([\\.:\u00a0\u2014 ]|$)",
          doc.parsed$text, ignore.case = TRUE) &
    !endsWith(doc.parsed$text, "(Continued)") &
    (nchar(doc.parsed$text) < 300) # catch some bad item lines
  doc.parsed$item <- cumsum(item.lines)

  items <- doc.parsed[item.lines, c("part", "item", "text", "original_order")]
  items$text <- gsub("[\u00a0[:space:]]+", " ", items$text)
  # items$item.number <- gsub("(*UCP)^item\\s*|\\..*", "", items$text, perl = TRUE)
  names(items)[names(items) == "text"] <- "item.name"
  # Strip the starting Part if present
  items$item.name <- gsub("^part [IV]{1,3}\\. ", "", items$item.name,
                          ignore.case = T)

  ##
  # Remove parts/items w/in the TOC
  # Items in TOC end with a page number
  last.toc.part <- -1
  last.toc.item <- -1
  toc.items <- grep(
     "^item[[:space:]\u00a0]+[[:digit:]]{1}[[:alnum:]]{0,2}.*\\b[[:digit:]]+$",
     items$item.name, ignore.case = TRUE)
  # toc.items <- grep("\\b[[:digit:]]+$", items$item.name)
  if (length(toc.items) > 0) {
    last.toc.part <- items$part[max(toc.items)]
    last.toc.item <- items$item[max(toc.items)]
  }

  parts <- parts[parts$part > last.toc.part, c("part", "part.name")]
  items <- items[items$item > last.toc.item, c("part", "item", "item.name")]

  doc.parsed <- merge(doc.parsed, parts, all.x = TRUE)
  doc.parsed <- merge(doc.parsed, items, by = c("part", "item"), all.x = TRUE)
  doc.parsed[is.na(doc.parsed$part.name), "part.name"] <- ""
  doc.parsed[is.na(doc.parsed$item.name), "item.name"] <- ""

  doc.parsed <- doc.parsed[order(doc.parsed$original_order),
                           c(return_cols, "part.name", "item.name")]
  rownames(doc.parsed) <- NULL

  return(doc.parsed)
}
