#' Parse Submission
#'
#' Raw SEC filings are sent in a SGML file - this parses that master submission
#' into component documents, with content lines in list column 'TEXT'.
#'
#' Most of the time the information you need along with the specific files
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
#'           filing over many filings, there can be efficiency gains from just
#'           downloading a single file.}
#'   }
#'
#' \emph{NOTE: non-text documents are uuencoded and need a separate decoder to be
#' viewed.}
#'
#' @param x - Input submission to parse. May be one of the following:
#'   \describe{
#'     \item{URI}{URL to a SEC complete submission text file}
#'     \item{Text}{String with the full submission}
#'     \item{File path}{Path to local file containing the submission}
#'   }
#' @param include.binary - Default TRUE, determines if the content of binary
#'        documents is returned.
#' @param include.content - Default TRUE, determines if the content of
#'        documents is returned.
#'
#' @return a dataframe with one row per document. For the metadata (TYPE,
#'   DESCRIPTION, FILENAME) it is important to note that these are provided by
#'   the filer and have little standardization or enforcement.
#'   \describe{
#'     \item{SEQUENCE}{Sequence number of the file}
#'     \item{TYPE}{The type of document, e.g. 10-K, EX-99, GRAPHIC}
#'     \item{DESCRIPTION}{The type of document, e.g. 10-K, EX-99, GRAPHIC}
#'     \item{FILENAME}{The document's filename}
#'     \item{TEXT}{The text representation of the document. For text-based
#'       documents (txt, html) this is the actual file contents. For binary
#'       files (graphics, pdfs) this contains the uuencoded contents.}
#'   }
#'
#' @examples
#' \donttest{
#' try(
#'   parse_submission(paste0('https://www.sec.gov/Archives/edgar/data/',
#'                    '37996/000003799617000084/0000037996-17-000084.txt'))[ ,
#'                      c('SEQUENCE', 'TYPE', 'DESCRIPTION', 'FILENAME')]
#'   )
#' }
#' @export
parse_submission <- function(x,
                             include.binary = T,
                             include.content = T) {
  res <- charToText(x)

  # Checking if we have an SEC document is more efficient than checking if every
  # string is a file
  is.secdoc <- any(startsWith(res, c("-----BEGIN PRIVACY-ENHANCED MESSAGE-----",
                                     "<SEC-DOCUMENT")))
  if (is.secdoc & (nchar(res) > 8e6)) {
    # For large documents, use a tmp file for processing
    f <- tempfile()
    con <- file(f, "wb")
    writeChar(res, con)
    close(con)
    con <- file(f, "rt")
    res <- parse_submission.connection(con,
                                       include.binary = include.binary,
                                       include.content = include.content)
    close(con)
    unlink(f)
    return(res)
  } else if (!is.secdoc & file.exists(res)) {
    con <- file(res, "rt")
    res <- parse_submission.connection(con,
                                       include.binary = include.binary,
                                       include.content = include.content)
    close(con)
    return(res)
  } else if (!is.secdoc) {
    stop("Not an SEC submission document")
  }

  parts <- data.frame(text = unlist(strsplit(res, "\n")),
                      stringsAsFactors = FALSE)
  parts$doc <- cumsum("<DOCUMENT>" == parts$text)
  parts$in.text <- cumsum(("<TEXT>" == parts$text) -
                          ("</TEXT>" == parts$text))

  docs <- parts[parts$in.text == 0 &
                parts$doc > 0 &
                parts$text != "<DOCUMENT>" &
                startsWith(parts$text, "<") &
                !startsWith(parts$text, "</"), ]
  docs$key <- sub("^<([A-Z]+)>.*$", "\\1", docs$text)
  docs$val <- sub("^<[A-Z]+>(.*)$", "\\1", docs$text)

  doc.ids <- unique(docs$doc)
  doc.val <- function(doc.id, col.name) {
    val <- docs[docs$doc == doc.id &
                docs$key == col.name, "val"]
    return(ifelse(length(val) == 0, "", val))
  }

  cols <- c("TYPE", "SEQUENCE", "FILENAME", "DESCRIPTION")
  res <- sapply(cols, function(key) {
    return(sapply(doc.ids, doc.val, key, simplify = TRUE))
  })
  res <- data.frame(rbind(res), stringsAsFactors = FALSE)
  rownames(res) <- NULL

  get.lines <- function(doc.id) {
    if (!include.content) {
      return("")
    }

    lines <- parts$text[parts$doc == doc.id &
                        parts$in.text == 1 &
                        parts$text != "<TEXT>"]

    # Check if this is a uuencoded chunk
    is.binary <- substring(lines[1], 1, 6) == "begin " &
                 lines[length(lines)] == "end"
    if (is.binary & !include.binary) {
      return("")
    }
    if (is.binary) {
        # If it is, make sure all the lines are the correct length
        lines[2:length(lines) - 1] <- sprintf("%-61s",
                                              lines[2:length(lines) - 1])
    }

    return(clean_sgml_text(lines))
  }
  res$TEXT <- unlist(lapply(doc.ids, get.lines))

  return(res)
}

#' @noRd
parse_submission.connection <- function(con,
                                        include.binary = T,
                                        include.content = T) {
  keys <- c("TYPE", "SEQUENCE", "FILENAME", "DESCRIPTION")
  tags <- paste0("<", keys, ">")
  result <- data.frame(matrix(NA, nrow = 0, ncol = length(keys) + 1),
                       stringsAsFactors = F)
  names(result) <- c(keys, "TEXT")

  in.text <- F
  is.binary <- F
  text.line <- 0
  content <- c()
  while (length(l <- readLines(con, n = 1, warn = F)) > 0) {
    if (in.text) {
      if (startsWith(l, "</TEXT>")) {
        in.text <- F
      } else {
        text.line <- text.line + 1
        if (text.line == 1 & startsWith(l, "begin ")) {
          is.binary <- T
        }
        if (include.content & (!is.binary || include.binary)) {
          content <- c(content, l)
        }
      }
      next
    }
    # New document, start a new row
    if (startsWith(l, "<DOCUMENT")) {
      file.row <- as.list(rep("", length(keys) + 1))
      names(file.row) <- c(keys, "TEXT")
    }
    if (any(startsWith(l, tags))) {
      file.row[keys[startsWith(l, tags)]] <- substr(l,
                                                   nchar(tags[startsWith(l, tags)]) + 1,
                                                   nchar(l))
    }
    if (startsWith(l, "</DOCUMENT")) {
      file.row$TEXT <- clean_sgml_text(content)
      result <- rbind(result, file.row, stringsAsFactors = F)
      # message(file.row$SEQUENCE, " ", file.row$FILENAME, " - [", text.line,
      #         "] ", nchar(file.row$TEXT))
    }
    if (startsWith(l, "<TEXT")) {
      in.text <- T
      is.binary <- F
      text.line <- 0
      content <- c()
    }
  }
  result
}

#' Cleans up quirks to sqml
#' specifically, when lines are trimmed to 1024 characters
#' @noRd
clean_sgml_text <- function(txt) {
  if (length(txt) == 1) {
    txt.lines <- unlist(strsplit(txt, "\n", fixed = T))
  } else {
    txt.lines <- txt
  }
  txt.length <- nchar(txt.lines)
  # If we don't need to clean, bailout
  if (!any(txt.length == 1023 | txt.length == 1025)) {
    return(paste0(txt.lines, collapse = "\n"))
  }
  # leading dashes are escaped... weirdly
  prior.long <- c(F, (txt.length == 1023 | txt.length == 1025)[-length(txt.length)])
  txt.lines[prior.long & txt.length == 1025] <- sub("^- ", "",
                                                    txt.lines[prior.long & txt.length == 1025])
  txt.lines[txt.length < 1023] <- paste0(txt.lines[txt.length < 1023], "\n")
  paste0(txt.lines, collapse = "")
}
