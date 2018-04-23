#' Submission URL Tools
#'
#' EDGAR submissions are organized fairly regularly. These functions help to
#' fint the URL to submission components.
#' @param cik Company code
#' @param accession accession number for a filing
#' @param filename filename provided in a submission
#' @return A string with URL requested
#' @examples
#' submission_index_href("0000712515", "0000712515-17-000090")
#' submission_href("0000712515", "0000712515-17-000090")
#' submission_file_href("0000712515", "0000712515-17-000090",
#'                      "pressrelease-ueberroth.htm")
#' @export
submission_index_href <- function(cik, accession) {
  submission_file_href(cik, accession, paste0(accession, "-index.htm"))
}

#' @describeIn submission_index_href Creates a link to the master submission
#' sgml submission file
#' @export
submission_href <- function(cik, accession) {
  submission_file_href(cik, accession, paste0(accession, ".txt"))
}

#' @describeIn submission_index_href provides the link to a given file within a
#' particular submission.
#' @export
submission_file_href <- function(cik, accession, filename) {
  trim_cik <- gsub("^0+", "", cik)
  dashless <- gsub("-", "", accession)
  paste0("https://www.sec.gov/Archives/edgar/data/", trim_cik, "/", dashless,
         "/", filename)
}

is_url <- function(x) {
  grepl("^(http|ftp)s?://", x, ignore.case = T)
}

get_doc <- function(x, clean = F) {
  if (typeof(x) == "character") {
    if (is_url(x)) {
      res <- httr::GET(x)
      content <- httr::content(res, encoding = "UTF-8", as = "text")
      if (clean) {
        content <- clean_html(content)
      }
      doc <- xml2::read_html(content, base_url = x)
    } else {
      if (clean) {
        content <- clean_html(x)
      } else {
        content <- x
      }
      doc <- xml2::read_html(content)
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
  # Not cleaned:
  # "&#254;"  - thorn
  # "&#167;"  - sect
  # "&#174;"  - reg
  # "&#8482;" - trade
  # "&#8226;" - bullet

  x <- gsub("&nbsp;", " ", x, ignore.case = T)
  x <- gsub("\u00a0", " ", x, fixed = T) # Unicode nbsp
  x <- gsub("&#160;", " ", x, ignore.case = T)
  x <- gsub("&#32;", " ", x, ignore.case = T)


  x <- gsub("&#151;", " - ", x, ignore.case = T)
  x <- gsub("&#8211;", " - ", x, ignore.case = T) # ndash
  x <- gsub("&#8212;", " - ", x, ignore.case = T) # mdash
  x <- gsub("\u0097", " - ", x, fixed = T) # EM dash (i think)

  x <- gsub("&#146;", "'", x, ignore.case = T) # possessive quote
  x <- gsub("&#8217;", "'", x, ignore.case = T) # another possessive quote
  x <- gsub("&#8220;", "\"", x, ignore.case = T) # left double quote
  x <- gsub("&#8221;", "\"", x, ignore.case = T) # right double quote

  # xml_text doesn't break words on div closes, which we typically want
  x <- gsub("</div>", "</div> ", x, fixed = T)

  x <- gsub("<br>", " ", x, ignore.case = T)
  x <- gsub("<br/>", " ", x, ignore.case = T)
  x <- gsub("<page>", " ", x, ignore.case = T)
  x
}

# removes br from the doc since we don't really care about display, replacing
# with spaces
clean_doc <- function(doc) {
  replacement <- xml2::xml_find_first(xml2::read_xml("<p> </p>"),
                                      "/p/text()")
  xml2::xml_replace(xml2::xml_find_all(doc, "//br"), replacement)

  # remove hidden divs
  xml2::xml_remove(xml2::xml_find_all(doc, "//div[@style = 'display:none']"),
                   free = T)

  # Don't care about non-text divs
  xml2::xml_remove(xml2::xml_find_all(doc, "//div[(count(*) = 0 or count(hr) =
                                      count(*)) and normalize-space() = '']"), free = T)

  # strip messy inlineXBRL
  if (length(xml2::xml_ns(doc)) > 1) {
    xml2::xml_remove(xml2::xml_find_all(doc, "//header"), free = T)
  }

  doc
}
