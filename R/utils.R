is_url <- function(x) {
  grepl("^(http|ftp)s?://", x)
}

charToDoc <- function(x) {
  if (is_url(x)) {
    res <- httr::GET(x)
    xml2::read_html(res, base_url = x)
  } else {
    xml2::read_html(x)
  }
}
