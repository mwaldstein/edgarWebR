#' Parse Submission
#'
#' Raw SEC filings are sent in a SGML file - this parses that master submission
#' into component documents, with content lines in list column 'TEXT'.
#'
#' Most of the time the information you need along with the sepecific files
#' will be available by using \code{\link{filing_documents}}, but there are
#' scenarios where you may want to access the full contents of the master
#' submission - 
#'   \describe{
#'     \item{Old Submissions}{Older submissions are not parsed into component
#'           documents by the SEC so access requires parsing the main filing}
#'     \item{Full Document List}{The SEC only provides what it considers the
#'           relevant documents, but filings often include many more ancillary
#'           files}
#'     \item{Efficient Downloading}{If you're fetching many documents from a
#'           filing over many filings, there can be effiency gains fromjust
#'           downloading a single file.}
#'   }
#'
#' *NOTE:* non-text documents are uuencoded and need a sepate decoder to be
#' viewed.
#'
#' @param uri - URL to a SEC complete submiision text file
#'
#' @return a dataframe with one row per document.
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
