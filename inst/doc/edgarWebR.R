## ----setup, echo = FALSE, message = FALSE--------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
library(edgarWebR)
library(dplyr)
library(purrr)
library(ggplot2)
set.seed(0451)

## ----companyInfo---------------------------------------------------------
ticker <- "EA"

filings <- company_filings(ticker, type = "10-", count = 100)
initial_count <- nrow(filings)
# Specifying the type provides all forms that start with 10-, so we need to
# manually filter.
filings <- filings[filings$type == "10-K" | filings$type == "10-Q", ]

## ------------------------------------------------------------------------
filings$md_href <- paste0("[Link](", filings$href, ")")
knitr::kable(tail(filings)[, c("type", "filing_date", "accession_number", "size",
                               "md_href")],
             col.names = c("Type", "Filing Date", "Accession No.", "Size", "Link"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----filingInfo,cache = TRUE---------------------------------------------
# this can take a while - we're fetching ~100 html files!
filing_infos <- map_df(filings$href, filing_information)

filings <- bind_cols(filings, filing_infos)
filings$filing_delay <- filings$filing_date - filings$period_date

# Take a peak at the data
knitr::kable(head(filings) %>% select(type, filing_date, period_date,
                                      filing_delay, documents, bytes) %>%
             mutate(filing_delay = as.numeric(filing_delay)),
             col.names = c("Type", "Filing Date", "Period Date", "Delay",
                           "Documents", "Size (B)"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----filingAnalysis------------------------------------------------------
knitr::kable(filings %>%
             group_by(type) %>% summarize(
               n = n(),
               avg_delay = as.numeric(mean(filing_delay)),
               median_delay = as.numeric(median(filing_delay)),
               avg_size = mean(bytes / 1024),
               avg_docs = mean(documents)
             ),
             col.names = c("Type", "Count", "Avg. Delay", "Median Delay",
                           "Avg. Size", "Avg. Docs"),
             digits = 2,
             format.args = list(big.mark = ","))

## ----plotDelay, fig.width=6----------------------------------------------
ggplot(filings, aes(x = factor(type), y = filing_delay)) +
  geom_violin() + geom_jitter(height = 0, width = 0.1) +
  labs(x = "Filing Date", y = "Filing delay (days)")

## ----plotType, fig.width=6-----------------------------------------------
ggplot(filings, aes(x = filing_date, y = filing_delay, group = type, color = type)) +
  geom_point() + geom_line() +
  labs(x = "Filing Type", y = "Filing delay (days)")

## ----plotSize, fig.width=6-----------------------------------------------
ggplot(filings, aes(x = filing_date, y = bytes / 1024, group = type, color = type)) +
  geom_point() + geom_line() +
  labs(x = "Filing Type", y = "Filing Size (KB)")

## ----eval=FALSE----------------------------------------------------------
#  install.packages("edgarWebR")

## ----eval=FALSE----------------------------------------------------------
#  # install.packages("devtools")
#  devtools::install_github("mwaldstein/edgarWebR")

