## ----setup, echo = FALSE, message = FALSE--------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
library(edgarWebR)
set.seed(0451)

## ----companyInfo---------------------------------------------------------
ticker <- "STX"

filings <- company_filings(ticker, type = "10-Q", count = 40)
# Specifying the type provides all forms that start with 10-, so we need to
# manually filter.
filings <- filings[filings$type == "10-Q", ]
# We're only interested in a particular filing
filing <- filings[filings$filing_date == "2017-10-27", ]
filing$md_href <- paste0("[Link](", filing$href, ")")
knitr::kable(filing[, c("type", "filing_date", "accession_number", "size",
                                "md_href")],
             col.names = c("Type", "Filing Date", "Accession No.", "Size", "Link"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----document------------------------------------------------------------
docs <- filing_documents(filing$href)
doc <- docs[docs$description == 'Complete submission text file', ]
doc$md_href <- paste0("[Link](", doc$href, ")")

knitr::kable(doc[, c("seq", "description", "document", "size",
                     "md_href")],
             col.names = c("Sequence", "Description", "Document",
                           "Size", "Link"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----parse_submission----------------------------------------------------
parsed_docs <- parse_submission(doc$href)
knitr::kable(head(parsed_docs[, c("SEQUENCE", "TYPE", "DESCRIPTION", "FILENAME")]),
             col.names = c("Sequence", "Type", "Description", "Document"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----parse_submission_tail-----------------------------------------------
knitr::kable(tail(parsed_docs[, c("SEQUENCE", "TYPE", "DESCRIPTION", "FILENAME")]),
             col.names = c("Sequence", "Type", "Description", "Document"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----show_text-----------------------------------------------------------
# NOTE: the filing document is not always #1, so it is a good idea to also look
# at the type & Description
filing_doc <- parsed_docs[parsed_docs$TYPE == '10-Q' &
                          parsed_docs$DESCRIPTION == '10-Q', 'TEXT']
substr(filing_doc, 1, 80)

## ----parseFiling---------------------------------------------------------
doc <- parse_filing(filing_doc, include.raw = TRUE)
unique(doc$part.name)
unique(doc$item.name)
head(doc[grepl("market risk", doc$item.name, ignore.case = TRUE), "text"], 3)
risks <- doc[grepl("market risk", doc$item.name, ignore.case = TRUE), "raw"]

## ----parseRisks----------------------------------------------------------
risks <- risks[grep("<i>", risks)]
risks <- gsub("^.*<i>|</i>.*$", "", risks)
risks <- gsub("\n", " ", risks)
risks

## ----eval=FALSE----------------------------------------------------------
#  install.packages("edgarWebR")

## ----eval=FALSE----------------------------------------------------------
#  # install.packages("devtools")
#  devtools::install_github("mwaldstein/edgarWebR")

