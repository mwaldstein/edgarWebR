library('edgarWebR')
library('httpcache')
library('xml2')
library('memoise')

cache <- './10cache.rds'
in.file <- './10k_href.csv'
out.file <- sub('.csv', '.out.csv', in.file)
out.bad.file <- sub('.csv', '.out.bad.csv', in.file)

if (file.exists(cache)) {
    loadCache(cache)
}

ref <- read.csv(in.file, stringsAsFactors=FALSE)

calc <- function(url) {
  doc <- read_html(GET(url))
  res <- parse_filing(doc)
  return(list(
    nParts = length(unique(res$part.name)),
    nItems = length(unique(res$item.name)),
    nRow = nrow(res)
  ))
}

ref <- cbind(ref, t(sapply(ref$href, calc)))
ref$nRow <- unlist(ref$nRow)
ref$nParts <- unlist(ref$nParts)
ref$nItems <- unlist(ref$nItems)

write.csv(ref, out.file, row.names = FALSE)
bad <- ref[
  ref$nParts != 5 |
  !(ref$nItems %in% c(16,21)), ]
write.csv(bad, out.bad.file, row.names = FALSE)

saveCache(cache)
