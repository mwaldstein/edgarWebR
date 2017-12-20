library("edgarWebR")
library("httpcache")
library("xml2")
library("memoise")

cache <- "./10cache.rds"
in.file <- "./10k_href.csv"
out.file <- sub(".csv", ".out.csv", in.file)
bad.file <- sub(".csv", ".out.bad.csv", in.file)

if (file.exists(cache)) {
  httpcache::loadCache(cache)
}

ref <- read.csv(in.file, stringsAsFactors = FALSE)

calc <- function(url) {
  doc <- xml2::read_html(httpcache::GET(url))
  res <- edgarWebR::parse_filing(doc)
  return(list(
    n.parts = length(unique(res$part.name)),
    n.items = length(unique(res$item.name)),
    n.row = nrow(res)
  ))
}

ref <- cbind(ref, t(sapply(ref$href, calc)))
ref$n.row <- unlist(ref$n.row)
ref$n.parts <- unlist(ref$n.parts)
ref$n.items <- unlist(ref$n.items)

write.csv(ref, out.file, row.names = FALSE)
bad <- ref[
  ref$n.parts != 5 |
  !(ref$n.items %in% c(16, 21)), ]
write.csv(bad, bad.file, row.names = FALSE)

httpcache::saveCache(cache)
