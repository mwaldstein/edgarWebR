context("running company_filings")

with_mock_API({
test_that("running", {
  expect_error(company_filings("BAD"))
  res <- company_filings("AAPL")
  expect_is(res, "data.frame")

  expect_length(res, 11)
  expect_equal(nrow(res), 40)
})

test_that("type filtering", {
  # Test with before to avoid new filings.
  res <- company_filings("AAPL", type = "10-K", before = "20170801")
  expect_equal(nrow(res), 25)
})
})
