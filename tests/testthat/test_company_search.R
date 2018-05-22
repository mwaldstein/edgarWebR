context("running company_search")

with_mock_API({
  test_that("Multipe Results", {
    res <- company_search("delhaize")
    expect_length(res, 19)
    expect_equal(nrow(res), 3)
    expect_equal(res$state_location, c("NC", "C9", "NC"))
  })
  test_that("Single Result", {
    res <- company_search("delhaize america")
    expect_length(res, 19)
    expect_equal(nrow(res), 1)
    expect_equal(res$cik, "0000037912")
  })
  test_that("Many, many results", {
    res <- company_search("llc", match = "contains")
    expect_length(res, 19)
    expect_equal(nrow(res), 40)
  })
  test_that("Type N-PX", {
    res <- company_search("vanguard", type = "N-PX")
    expect_length(res, 19)
    expect_equal(nrow(res), 38)
  })
})
