#' Parse Submission
#'
#' SEC filings are sent in a SGML file - this parses that master submission
#' into component documents, with content lines in a nested tibble.
#'
#' *NOTE:* non-text documents are uuencoded.
#'
#' @param uri - URL to a SEC complete submiision text file
#'
#' @return a tibble with one row per document, the content nested in TEXT
#'
#' @examples
#' parse_submission('https://www.sec.gov/Archives/edgar/data/37996/000003799617000084/0000037996-17-000084.txt')
#' @export
parse_submission <- function (uri) {
  res <- getText(uri)

  parts <- data.frame(text = unlist(strsplit(res, "\n"))) %>%
           dplyr::mutate(doc = cumsum(grepl("^<DOCUMENT>$", text)),
                  inText = cumsum(grepl("^<TEXT>$", text) -
                                  grepl("^</TEXT>$", text)))

  non_text <- parts %>% dplyr::filter(inText == 0,
                               doc >= 1,
                               text != "<DOCUMENT>",
                               substr(text,1,1) == "<",
                               substr(text,2,2) != "/"
                               ) %>%
              dplyr::mutate(key = sub("^<([A-Z]+)>.*$", "\\1", text),
                     val = sub("^<[A-Z]+>(.*)$", "\\1", text)) %>%
              dplyr::select(-inText, -text) %>%
              tidyr::spread(key, val)
  parts <- parts %>% dplyr::filter(inText == 1,
                            text != "<TEXT>") %>%
                     dplyr::select(-inText) %>%
                     dplyr::rename("TEXT" = "text") %>%
                     tidyr::nest(TEXT, .key="TEXT") %>%
                     dplyr::left_join(non_text, by = "doc") %>%
                     dplyr::select(-doc)

  # Older filings don't include filenames, this ensures that the column extists
  # if needed
  if (! "FILENAME" %in% colnames(parts)) {
    parts$FILENAME <- ""
  }

  return(parts)
}
