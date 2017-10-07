#' Parse Submission
#'
#' SEC filings are sent in a SGML file - this parses that master submission
#' into component documents, with content lines in list column 'TEXT'.
#'
#' *NOTE:* non-text documents are uuencoded and likely are missing needed
#' padding on lines to allow uudecode to work.
#'
#'
#' @param uri - URL to a SEC complete submiision text file
#'
#' @return a tibble with one row per document, the content nested in TEXT
#'
#' @examples
#' parse_submission(paste0('https://www.sec.gov/Archives/edgar/data/',
#'                  '37996/000003799617000084/0000037996-17-000084.txt'))
#' @export
parse_submission <- function (uri) {
  res <- charToText(uri)

  parts <- data.frame(text = unlist(strsplit(res, "\n")),
                      stringsAsFactors = FALSE)
  parts$doc <- cumsum(grepl("^<DOCUMENT>$", parts$text))
  parts$in.text <- cumsum(grepl("^<TEXT>$", parts$text) -
                          grepl("^</TEXT>$", parts$text))

  docs <- parts[parts$in.text == 0 &
                parts$doc > 0 &
                parts$text != "<DOCUMENT>" &
                substr(parts$text, 1, 1) == "<" &
                substr(parts$text, 2, 2) != "/", ]
  docs$key <- sub("^<([A-Z]+)>.*$", "\\1", docs$text)
  docs$val <- sub("^<[A-Z]+>(.*)$", "\\1", docs$text)

  doc.ids <- unique(docs$doc)
  doc.val <- function(doc.id, col.name) {
    val <- docs[docs$doc == doc.id &
                docs$key == col.name, "val"]
    return(ifelse(typeof(val) == "character", val, ""))
  }

  cols <- c("TYPE", "SEQUENCE", "FILENAME", "DESCRIPTION")
  res <- sapply(cols, function(key) {
    return(sapply(doc.ids, doc.val, key, simplify = TRUE))
  })
  res <- data.frame(res, stringsAsFactors = FALSE)

  get.lines <- function(doc.id) {
    lines <- parts[parts$doc == doc.id &
                   parts$in.text == 1 &
                   parts$text != "<TEXT>", "text"]

    # Check if this is a uuencoded chunk
    if (substring(lines[1], 1, 6) == "begin " &
        lines[length(lines)] == "end") {
        # If it is, make sure all the lines are the correct length
        lines[2:length(lines) - 1] <- sprintf("%-61s",
                                              lines[2:length(lines) - 1])
    }

    return(paste0(lines, collapse = "\n"))
  }
  res$TEXT <- unlist(lapply(doc.ids, get.lines))

  return(res)
}
