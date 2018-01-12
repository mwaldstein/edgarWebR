library("edgarWebR")

#href <- "https://www.sec.gov/Archives/edgar/data/732712/000119312509036349/d10k.htm#tx90102_1"
href <-
  "https://www.sec.gov/Archives/edgar/data/20947/000103129610000011/form10k.htm"
out <- "~/public_html/parse_out.html"

res <- parse_filing(href, include.raw = T)
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
