context("running parse_filing")

# The XPath for filing_filers is particularly complex, so it is particularly
# important to test a wide range of values

with_mock_API({
  test_that("Basics (type 10-Q)", {
    href <- "https://www.sec.gov/Archives/edgar/data/712515/000071251517000010/ea12312016-q3fy1710qdoc.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 695)

    # A couple of spot checks.
    expect_equal(length(unique(res$part.name)), 3)
    expect_equal(length(unique(res$item.name)), 11)
    expect_equal(length(unique(res[startsWith(res$part.name, "PART I "),
                               "item.name"])), 5)
    expect_equal(length(unique(res[startsWith(res$part.name, "PART II "),
                               "item.name"])), 7)
  })
  test_that("Basics (type 10-Q - STX)", {
    href <- "https://www.sec.gov/Archives/edgar/data/1137789/000119312517148855/d381726d10q.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 500)

    # A couple of spot checks.
    expect_equal(length(unique(res$part.name)), 3)
    expect_equal(length(unique(res$item.name)), 12)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 5)
    expect_equal(length(unique(res[startsWith(res$part.name, "PART II"),
                               "item.name"])), 8)
  })
  test_that("Handles parsed docs", {
    href <- "https://www.sec.gov/Archives/edgar/data/712515/000071251517000010/ea12312016-q3fy1710qdoc.htm"
    doc <- xml2::read_html(href)
    res <- parse_filing(href, strip = FALSE, include.raw = TRUE)
    expect_is(res, "data.frame")
    expect_length(res, 4)
    expect_equal(nrow(res), 1197)
  })
  test_that("Handles 8-K", {
    href <- "https://www.sec.gov/Archives/edgar/data/320193/000162828017000663/a8-kq1201712312016.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 35)
    expect_equal(length(unique(res$part.name)), 1)
    # This is failing because there are no parts, so it isn't pulling any items
    expect_equal(length(unique(res$item.name)), 3)
  })
  test_that("Handles 10-K (edgarx.com)", {
    href <- "https://www.sec.gov/Archives/edgar/data/38264/000100329716000907/forward10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(nrow(res), 554)
  })
  test_that("Handles 10-K (Ford)", {
    href <- "https://www.sec.gov/Archives/edgar/data/37996/000003799617000013/f1231201610-k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 23)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(nrow(res), 1675)
  })
})
