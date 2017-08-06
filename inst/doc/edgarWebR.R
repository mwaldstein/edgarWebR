## ---- echo = FALSE, message = FALSE--------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
library(edgarWebR)
set.seed(0451)

## ------------------------------------------------------------------------
ticker <- "EA"

filings <- company_filings(ticker, type="10-", count=100)
# Specifying the type provides all forms that start with 10-, so we need to
# manually filter.
filings <- filings[filings$type == "10-K" | filings$type == "10-Q",]
knitr::kable(tail(filings)[,c("filing_date","accession","size", "href")])

## ----cache=TRUE----------------------------------------------------------
# this can take a while - we're fetching ~100 html files!
filings$info <- lapply(filings$href, filing_information) 

# pull relevant fields out of the info
filings$filing_delay <- sapply(filings$info, function(info) {
                                 info$filing_date - info$period_date})
filings$filing_size <- sapply(filings$info, function(info) {info$filing_bytes})
filings$documents <- sapply(filings$info, function(info) {info$documents})

## ------------------------------------------------------------------------
library(dplyr)
library(ggplot2)

filings <- filings %>% select(type, filing_date, filing_delay, filing_size,
                              documents)

knitr::kable(filings %>% 
             select(-filing_date) %>% # group_by doesn't like date classes
             group_by(type) %>% summarize(
               n=n(),
               `mean delay (days)` = mean(filing_delay),
               `median delay (days)` = median(filing_delay),
               `mean size (KB)` = mean(filing_size / 1024),
               `mean documents (count)` = mean(documents)
             )
            )

## ----fig.width=6---------------------------------------------------------
ggplot(filings, aes(x = factor(type), y=filing_delay)) +
  geom_violin() + geom_jitter(height = 0, width = 0.1) +
  labs(x = "Filing Date", y = "Filing delay (days)")

## ----fig.width=6---------------------------------------------------------
ggplot(filings, aes(x = filing_date, y=filing_delay, group=type, color=type)) + 
  geom_point() + geom_line() +
  labs(x = "Filing Type", y = "Filing delay (days)")

## ----fig.width=6---------------------------------------------------------
ggplot(filings, aes(x = filing_date, y=filing_size/1024, group=type, color=type)) + 
  geom_point() + geom_line() +
  labs(x = "Filing Type", y = "Filing Size (KB)")

## ----eval=FALSE----------------------------------------------------------
#  # install.packages("devtools")
#  devtools::install_github("mwaldstein/edgarWebR")

