context("running filing_information")

test_that("Basics (type 4)", {
            href <- "https://www.sec.gov/Archives/edgar/data/1333712/000156218017002633/0001562180-17-002633-index.htm"
            res <- filing_information(href)
            expect_is(res, "data.frame")
            expect_length(res, 10)
            expect_equal(nrow(res), 1)

            expect_equal(res$type, "4")
            expect_equal(res$description, "Statement of changes in beneficial ownership of securities:")
            expect_equal(res$accession_number, "0001562180-17-002633")
            expect_equal(res$documents, 1)
            expect_equal(res$bytes, 5803)

            expect_is(res$filing_date, "POSIXct")
            expect_equal(res$filing_date, as.POSIXct("2017-08-09"))
            expect_is(res$accepted_date, "POSIXct")
            expect_equal(res$accepted_date, as.POSIXct("2017-08-09 15:24:40"))
            expect_is(res$period_date, "POSIXct")
            expect_equal(res$period_date, as.POSIXct("2017-08-08"))
            expect_is(res$changed_date, "POSIXct")
            expect_equal(res$changed_date, as.POSIXct("2017-08-09"))
            expect_true(is.na(res$effective_date))
})

test_that("XML Doc functionality", {
            href <- "https://www.sec.gov/Archives/edgar/data/1333712/000156218017002633/0001562180-17-002633-index.htm"
            doc <- xml2::read_html(href)
            res <- filing_information(doc)

            expect_is(res, "data.frame")
            expect_length(res, 10)
            expect_equal(nrow(res), 1)

            expect_equal(res$documents, 1)
            expect_equal(res$bytes, 5803)

            expect_is(res$filing_date, "POSIXct")
            expect_equal(res$period_date, as.POSIXct("2017-08-08"))

})
