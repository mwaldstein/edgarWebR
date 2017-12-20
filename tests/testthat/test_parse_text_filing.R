context("running parse_text_filing")

with_mock_API({
  test_that("Ford 10-K", {
    href <-
      "https://www.sec.gov/Archives/edgar/data/37996/000003799602000015/v7.txt"
    res <- parse_text_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 1111)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res$item.name)), 17)
  })
  test_that("PERKINELMER 10-K", {
    href <-
      "https://www.sec.gov/Archives/edgar/data/31791/000095013501000920/b38210pee10-k405.txt"
    res <- parse_text_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 761)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res$item.name)), 15)
  })
})
