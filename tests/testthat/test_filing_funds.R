context("running filing_funds")

test_that("Basics (type 485APOS)", {
            href <- "https://www.sec.gov/Archives/edgar/data/933691/000093369117000309/0000933691-17-000309-index.htm"
            res <- filing_funds(href)
            expect_is(res, "data.frame")
            expect_length(res, 9)
            expect_equal(nrow(res), 215)

            # A couple of spot checks.
            # Only one CIK
            expect_equal(unique(res$cik), "0000933691")
            expect_equal(unique(res$cik_href), "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000933691")

            # No tickers in this set
            expect_true(is.na(unique(res$ticker)))

            # Every fund has a unique contract
            expect_length(unique(res$contract), 215)

            expect_equal(res$series[1], "S000001722")
            expect_equal(res$series_href[1], "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=S000001722")
            expect_equal(res$series_name[1], "JNL/MFS MID CAP VALUE FUND")
            expect_equal(res$contract[1], "C000004629")
            expect_equal(res$contract_href[1], "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=C000004629")
            expect_equal(res$contract_name[1], "JNL/MFS MID CAP VALUE FUND (A)")
})

test_that("Direct XML functionality", {
            href <- "https://www.sec.gov/Archives/edgar/data/933691/000093369117000309/0000933691-17-000309-index.htm"
            doc <- xml2::read_html(href)
            res <- filing_funds(doc)

            expect_is(res, "data.frame")
            expect_length(res, 9)
            expect_equal(nrow(res), 215)

})
