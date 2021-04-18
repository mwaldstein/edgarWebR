context("running full_text")

with_mock_api({
  test_that("basic search", {
    res <- full_text("intel")
    expect_length(res, 9)
    expect_equal(nrow(res), 99)
  })
  test_that("multiple forms", {
    res <- full_text(
       "\"Transition Report\"",
       type = c("10-K", "10-Q"),
       cik = "0000050863",
       from = "04/18/2016",
       to = "04/18/2021",
    )
    expect_length(res, 9)
    expect_equal(nrow(res), 21)
    expect_equal(sum(res$cik == "0000050863"), nrow(res))
    expect_equal(sum(res$sic == 3674), nrow(res))
    expect_equal(res[1, "company_name"],"INTEL CORP  (INTC)")
  })
  test_that("detailed check", {
    res <- full_text(
       "\"Transition Report\"",
       type = "10-K",
       cik = "0000050863",
       from = "04/18/2016",
       to = "04/18/2021",
    )
    expect_length(res, 9)
    expect_true(nrow(res) == 6)
    expect_equal(sum(res$cik == "0000050863"), nrow(res))
    expect_equal(sum(res$sic == 3674), nrow(res))
    expect_equal(res[1, "company_name"],"INTEL CORP  (INTC)")
    expect_equal(sum(res$company_name == "INTEL CORP  (INTC)"), nrow(res))
    expect_equal(res[1, "name"],"10-K")
    expect_equal(sum(res$name == "10-K"), nrow(res))
  })
})
