## ---- echo = FALSE, message = FALSE--------------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
library(edgarWebR)
library(dplyr)
library(purrr)
library(ggplot2)
set.seed(0451)

## ------------------------------------------------------------------------
ticker <- "EA"

filings <- company_filings(ticker, type="10-", count=100)
# Specifying the type provides all forms that start with 10-, so we need to
# manually filter.
filings <- filings[filings$type == "10-K" | filings$type == "10-Q",]
knitr::kable(tail(filings)[,c("filing_date","accession","size", "href")])

## ------------------------------------------------------------------------
knitr::kable(filings %>% 
             group_by(type) %>% summarize(
               n=n(),
               `mean delay (days)` = mean(filing_delay),
               `median delay (days)` = median(filing_delay),
               `mean size (KB)` = mean(filing_bytes / 1024),
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
ggplot(filings, aes(x = filing_date, y=filing_bytes/1024, group=type, color=type)) +
  geom_point() + geom_line() +
  labs(x = "Filing Type", y = "Filing Size (KB)")

## ----eval=FALSE----------------------------------------------------------
#  # install.packages("devtools")
#  devtools::install_github("mwaldstein/edgarWebR")

