context("running header_search")

with_mock_api({
  test_that("basic search", {
    res <- header_search("company-name = Apple")
    expect_length(res, 5)
    expect_equal(nrow(res), 81)
  })
  test_that("detailed check", {
    res <- header_search("company-name = Apple",
                         from = 2012,
                         to = 2015,
                         page = 2)
    expect_length(res, 5)
    expect_true(nrow(res) == 81)
    expect_equal(res$company_name[1], "Apple Hospitality REIT, Inc.")
    expect_equal(res$form[1], "SC 14D9/A")
  })
})
