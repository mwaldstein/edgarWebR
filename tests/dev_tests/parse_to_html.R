library("edgarWebR")
library("xml2")
library(dplyr, warn.conflicts = F)
library(tidytext)
library(tokenizers)

# href <- "https://www.sec.gov/Archives/edgar/data/20947/000103129610000011/form10k.htm"
# href <- "https://www.sec.gov/Archives/edgar/data/1041061/000104106109000077/form_10-k22309.htm"
href <- "https://www.sec.gov/Archives/edgar/data/732712/000119312509036349/d10k.htm"
href <- "https://www.sec.gov/Archives/edgar/data/826083/000095013406005149/d33857e10vk.htm"
href <- "https://www.sec.gov/Archives/edgar/data/831001/000120677410000406/citi_10k.htm"
href <- "https://www.sec.gov/Archives/edgar/data/96223/000009622310000004/leucadia200910k.htm"
href <- "https://www.sec.gov/Archives/edgar/data/1158449/000115844909000027/aap10k.htm"
href <- "https://www.sec.gov/Archives/edgar/data/97745/000009774514000014/tmok2013.htm"
out <- "~/public_html/parse_out.html"


build_parts <- function(doc, xpath_base) {
  # para.nodes <- c("font", paste0("h", seq(5)), "a", "b", "i", "u", "sup")

  # xpath_parts <- c(
  #   #
  #   paste0("//*[", paste0(c(
  #     paste0("count(.//*[",
  #            paste0("local-name() != '", para.nodes, "'", collapse = " and "),
  #          "]) = 0"),
  #     # paste0("local-name(ancestor::*[1]) != '", para.nodes, "'"),
  #     "local-name() != 'title'",
  #     "local-name() != 'td'"),
  #     collapse = " and "),
  #     "]"),
  #   # Unroll tables-as-formatting
  #   "//table[.//tr[count(td) > 1]]",
  #   "//table[not(.//tr[count(td) > 1])]/tr/td/*"
  #   )
# #  xpath_parts <- c("//text()[not(ancestor::table)]",
# #                   "//table")
  # xpath_parts <- paste0(xpath_base, xpath_parts)
  # nodes <- xml2::xml_find_all(doc, paste0(xpath_parts, collapse = " | "))

  # paths <- xml2::xml_path(nodes)
  # with.parent <- sapply(paths,
  #                       function(path) {
  #                         sum(startsWith(path, paths)) > 1
  #                       })
  # nodes <- nodes[!with.parent]
  # message("covered: ", sum(with.parent))

  # doc.parts <- data.frame(text = trimws(xml2::xml_text(nodes)),
  #                         raw = as.character(nodes),
  #                         path = xml_path(nodes),
  #                         name = xml_name(nodes),
  #                         stringsAsFactors = F)
  doc.parts <- edgarWebR:::build_parts(doc, "//text",
                                       include.raw = T,
                                       include.path = T)
  doc.parts$text <- trimws(doc.parts$text)
  doc.parts <- doc.parts[doc.parts$text != "", ]
  doc.parts$part.name <- ""
  doc.parts$item.name <- ""
  doc.parts
}

test_parse <- function() {
  parsed.words <- build_parts(doc, "//text") %>%
    select(-raw) %>%
    unnest_tokens(word, text) %>%
    select(word)
  message(nrow(parsed.words), " - ", length(raw.words))
  rows <- min(nrow(parsed.words), length(raw.words))
  tmp <- tibble(parsed = parsed.words$word[seq(rows)],
                raw = raw.words[seq(rows)]) %>%
         mutate(n = row_number())
  tmp
}

doc <- edgarWebR:::get_doc(href, clean = T)
raw.words <- doc %>% xml_find_first("//text") %>% xml_text %>% tokenize_words %>% unlist

#res <- parse_filing(href, include.raw = T)
res <- build_parts(edgarWebR:::get_doc(href, clean = T), "//text")
res$n <- c(1:nrow(res))

  t.rows <- paste0("<tr ",
                   ifelse(startsWith(res$text[1:length(res$text) - 1],
                                     res$text[2:length(res$text)]),
                          "style = 'background: #aff'",
                          "style = 'background: #fff'"),
                   "><td>", res$n,
                   "</td><td>", res$part.name,
                   "</td><td>", res$item.name,
                   "</td><td>", res$path,
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
