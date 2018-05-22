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


unicode_map <- matrix(c(
  160,  " ",
  32,   " ",
  8194, " ", # En Space
  8195, " ", # Em Space
  8203, "",  # Zero-width space

  ## Hyphens
  151,  " - ",
  8208, " - ", # Hyphen
  8209, " - ", # Non-breaking Hyphen
  8210, " - ", # Figure Dash
  8211, " - ", # En dash
  8212, " - ", # Em dash
  8213, " - ", # Horizontal Bar
  8722, " - ", # Minus Sign

  ## Quotes
  145,  "'", # Private use One
  146,  "'", # Possessive Quote
  8216, "'", # Left Single Quote
  8217, "'", # Right Single Quote
  147,  "\"", # Set Transmit State (renered as double quote)
  148,  "\"", # Cancel Character (renered as double quote)
  8220, "\"", # Left Double Quote
  8221, "\"", # Right Double Quote

  ## Other
  8232, "\n", # Line Separator
  8260, "/",   # Fraction Slash
  "038", "&"
), ncol = 2, byrow = T)

html_escape_map <- unlist(apply(unicode_map, 1, function(map) {
  int.code <- as.integer(map[1])
  res <- list()
  res[paste0("&#", map[1], ";")] <- map[2]
  res[paste0("&#x", as.hexmode(int.code), ";")] <- map[2]
  res[paste0("&#x", toupper(as.hexmode(int.code)), ";")] <- map[2]
  res
}))

## This is a highly curated list based on what is actually seen in filings
## rather than an exhaustive code mapping
html_escape_map <- list(
  "&#8232;" = "\n",
  "&#x2011;" = " - ",
  "&#8210;"  = " - ",
  "&#x2212;" = " - ",
  "&#x2010;" = " - ",
  "&#150;"   = " - ",
  "&#151;"   = " - ",
  "&#8208;"  = " - ",
  "&#8209;"  = " - ",
  "&#8211;"  = " - ",
  "&#8212;"  = " - ",
  "&#8213;"  = " - ",
  "&#8722;"  = " - ",
  "&#x2013;" = " - ",
  "&#x2014;" = " - ",
  "&#x2015;" = " - ",
  "&#x2018;" = "'",
  "&#x2019;" = "'",
  "&#8216;"  = "'",
  "&#8217;"  = "'",
  "&#145;"   = "'",
  "&#146;"   = "'",
  "&#x201C;" = "\"",
  "&#x201D;" = "\"",
  "&#147;"   = "\"",
  "&#148;"   = "\"",
  "&#8220;"  = "\"",
  "&#8221;"  = "\"",
  "&#xa0;"    = " ",
  "&#32;"    = " ",
  "&#160;"   = " ",
  "&#x2003;" = " ",
  "&#8195;"  = " ",
  "&#8194;"  = " ",
  "&#8203;"  = " ", #zero width space
  "&#8260;"  = "/",
  "&#038;"   = "&"
)

html_escape_map["&nbsp;"] <- " "
html_escape_map["\u00a0"] <- " " # Unicode nbsp

# strips difficult to handle html bits we don't really care about
# @param x text of an html document
clean_html <- function(x) {
  # Not cleaned:
  # CODE, Count from SP500 Filings
  # "&#254;"         # thorn
  # "&#167;"         # sect
  # "&#174;"         # reg
  # "&#1465;",1      # Hebrew Point Holam
  # "&#8206;",8      # Left to Right mark
  # "&#8224;",8415   # Dagger
  # "&#8225;",1331   # Double Dagger
  # "&#8226;",178544 # Bullet
  # "&#8230;",655    # Ellipsis
  # "&#8232;",2      # Line Separator
  # "&#8356;",81     # Lira Sign
  # "&#8360;",2      # Rupee Sign
  # "&#8361;",10     # Won Sign
  # "&#8364;",3717   # Euro
  # "&#8369;",6      # Peso
  # "&#8480;",2      # Service Mark
  # "&#8482;",3914   # Trademark
  # "&#8539;",50     # Vulgar Fraction 1/8
  # "&#8540;",44     # Vulgar Fraction 3/8
  # "&#8541;",41     # Vulgar Fraction 5/8
  # "&#8542;",67     # Vulgar Fraction 7/8
  # "&#8718;",23     # End of Proof
  # "&#8729;",26     # Bullet Operator
  # "&#8730;",47     # Square Root
  # "&#8800;",2      # Not Equal To
  # "&#8804;",110    # Less-than or equal to
  # "&#8805;",273    # Greater-than or equal to
  # "&#8901;",5      # Dot operator
  # "&#9632;",37     # Black Square
  # "&#9633;",15     # White Square
  # "&#9642;",4846   # Black Square Small
  # "&#9675;",76     # White Circle
  # "&#9679;",4552   # Black Circle
  # "&#9702;",2029   # White Bullet
  # "&#9744;",1191   # Ballot Box
  # "&#9745;",397    # Ballot box w/ Check
  # "&#9746;",552    # Ballot Box w/ X
  # "&#9830;",130    # Black Diamond Suit
  # "&#9472;",36     # Circled Digit 0

  # character.replacements = list(
  #   ## SPACES
  #   "&nbsp;"  = " ",
  #   "&#160;"  = " ",
  #   "&#32;"   = " ",
  #   "\u00a0"  = " ", # Unicode nbsp
  #   "&#8194;" = " ", # En Space
  #   "&#8195;" = " ", # Em Space
  #   "&#8203;" = "",  # Zero-width space

  #   ## Hyphens
  #   "&#151;"  = " - ",
  #   "&#8208;" = " - ", # Hyphen
  #   "&#8209;" = " - ", # Non-breaking Hyphen
  #   "&#8210;" = " - ", # Figure Dash
  #   "&#8211;" = " - ", # En dash
  #   "&#8212;" = " - ", # Em dash
  #   "&#8213;" = " - ", # Horizontal Bar
  #   "&#8722;" = " - ", # Minus Sign

  #   ## Quotes
  #   "&#146;"  = "'", # Possessive Quote
  #   "&#8216;" = "'", # Left Single Quote
  #   "&#8217;" = "'", # Right Single Quote
  #   "&#8220;" = "\"", # Left Double Quote
  #   "&#8221;" = "\"", # Right Double Quote

  #   ## Other
  #   "&#8232;" = "\n", # Line Separator
  #   "&#8260;" = "/"   # Fraction Slash
  # )

  for (escape in names(html_escape_map)) {
    x <- gsub(escape,
              html_escape_map[escape],
              x,
              fixed = T)
      # x <- gsub(intToUtf8(substr(escape, 3, nchar(escape) - 1)),
      #           character.replacements[escape],
      #           x,
      #           fixed = T)
  }

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
