library("edgarWebR")

#href <- "https://www.sec.gov/Archives/edgar/data/712515/000071251517000010/ea12312016-q3fy1710qdoc.htm"
#href <- "https://www.sec.gov/Archives/edgar/data/38264/000100329716000907/forward10k.htm"
#href <- "https://www.sec.gov/Archives/edgar/data/732712/000119312509036349/d10k.htm#tx90102_1"
href <- "https://www.sec.gov/Archives/edgar/data/1424844/000092290708000774/form10k_122308.htm"
parser <- "v1"
out <- "~/public_html/parse_out_v1.html"

res <- parse_filing(href, include.raw = T, parser = parser)
res$n <- c(1:nrow(res))

t.rows <- paste0("<tr><td>", res$n,
                 "</td><td>", res$part.name,
                 "</td><td>", res$item.name,
                 "</td><td>", res$raw,
                 "</td></tr>")

file.conn <- file(out, encoding = "UTF-8")
writeLines(c(
  "<!DOCTYPE html>",
  "<html>",
  "<head>",
  "<meta charset='utf-8' />",
  "</head>",
  "<body>",
  "<table border=1>",
  t.rows,
  "</table>",
  "</body>",
  "</html>"), file.conn)
close(file.conn)
