context("running latest_filings")

with_mock_API({
  test_that("basics", {
    res <- latest_filings()
    expect_length(res, 9)
    expect_equal(nrow(res), 40)
  })
})
