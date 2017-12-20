context("running company_details")

with_mock_API ({
  test_that("running", {
    expect_error(company_details("EAR"))
    res <- company_details("AAPL")
    expect_is(res, "list")

    expect_length(res, 2)
  })

  test_that("type filtering", {
    # Test with before to avoid new filings.
    res <- company_details("AAPL", type = "10-K", before = "20170801")
    expect_equal(nrow(res$filings[1]), 25)
  })

})
