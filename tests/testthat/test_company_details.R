context("running company_details")

test_that("running", {
            expect_error(company_details("EAR"))
            res <- company_details("AAPL")
            expect_is(res, "list")

            expect_length(res, 2)
})

test_that("type filtering", {
            # Test with before to avoid new filings.
            res <- company_details("AAPL", type = "10-K", before = "20170801")
            expect_equal(nrow(res$filings[1]), 25)
})

test_that("running with doc", {
            href <- "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000933691&CIK=0000933691&type=&dateb=&owner=include&start=0&count=40&output=atom"
            doc <- xml2::read_xml(href)
            res <- company_details(doc)
            expect_is(res, "list")
})
