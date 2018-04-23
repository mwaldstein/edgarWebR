context("running cik_search")

with_mock_API({
  test_that("One Result (Cloudera)", {
    res <- cik_search("cloudera")

    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 1)

    expect_equal(res$cik[1], "0001535379")
    expect_equal(res$company_href[1],
                 "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=1535379")
    expect_equal(res$company_name[1], "CLOUDERA, INC.")
  })
  test_that("100+ Results (Intel)", {
    res <- cik_search("intel")

    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 100)
  })
  test_that("No Results", {
    res <- cik_search("asdr")

    expect_is(res, "data.frame")
    expect_equal(nrow(res), 0)
  })
})
