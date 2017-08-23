context("running filing_details")

with_mock_API({
  test_that("Basics (type 4)", {
    href <- "https://www.sec.gov/Archives/edgar/data/1333712/000156218017002633/0001562180-17-002633-index.htm"
    res <- filing_details(href)
    expect_is(res, "list")

    expect_length(res$information, 10)
    expect_equal(nrow(res$information), 1)

    expect_length(res$documents, 6)
    expect_equal(nrow(res$documents), 3)

    expect_length(res$filers, 21)
    expect_equal(nrow(res$filers), 2)

    # No funds in this filing
    expect_length(res$funds, 0)
    expect_equal(nrow(res$funds), 0)
  })

  test_that("Use Doc (type 485APOS)", {
    href <- "https://www.sec.gov/Archives/edgar/data/933691/000093369117000309/0000933691-17-000309-index.htm"
    res <- filing_details(href)
    expect_is(res, "list")

    # NOTE: this is the same filing tested in filing_funds, so only
    # basic tests
    expect_length(res$funds, 9)
    expect_equal(nrow(res$funds), 215)
  })
})
