edgar_clean_url <- function(x) {
  x <- sub("https://www.sec.gov", "", x, fixed = TRUE)
  x <- sub("Archives/edgar/data/", "", x, fixed = TRUE)
  x <- sub("cgi-bin/", "", x, fixed = TRUE)
  x <- sub("https://searchwww.sec.gov/EDGARFSClient/jsp/", "", x, fixed = TRUE)
  x <- sub("https://efts.sec.gov/LATEST/", "", x, fixed = TRUE)

  return(x)
}

function(request) {
  request$url <- edgar_clean_url(request$url)
  return(request)
}
