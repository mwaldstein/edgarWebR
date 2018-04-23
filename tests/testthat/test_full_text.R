context("running full_text")

with_mock_API({
  test_that("basic search", {
    res <- full_text("intel")
    expect_length(res, 9)
    expect_equal(nrow(res), 10)
  })
  test_that("detailed check", {
    res <- full_text("\"Transition Report\"", type = "10-K", name = "Intel")
    expect_length(res, 9)
    expect_true(nrow(res) == 3 || nrow(res) == 4)
    expect_equal(sum(res$cik == 50863), nrow(res))
    expect_equal(sum(res$sic == 3674), nrow(res))
    expect_equal(sum(res$company_name == "INTEL CORP"), nrow(res))
    expect_equal(sum(res$name == "10-K for INTEL CORP"), nrow(res))
  })
})
