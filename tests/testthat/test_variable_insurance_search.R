context("running variable_insurance_search")

with_mock_api({
  test_that("running", {
    res <- variable_insurance_search("precious metals")
    expect_is(res, "data.frame")

    expect_length(res, 12)
    expect_equal(nrow(res), 79)
    expect_length(unique(res$class_id), 79)

    test.row <- res[75, ]
    expect_equal(test.row$class_id, "C000092800")
    expect_equal(test.row$class_name, "Administrator Class")
    expect_equal(test.row$cik, "0001081400")
  })

  test_that("fast search (Class)", {
    res <- variable_insurance_fast_search("C000191892")
    expect_is(res, "data.frame")

    expect_length(res, 12)
    expect_equal(nrow(res), 1)
    expect_length(unique(res$class_id), 1)

    test.row <- res[1, ]
    expect_equal(test.row$class_id, "C000191892")
    expect_equal(test.row$class_name, "Class T")
    expect_equal(test.row$cik, "0000725781")
  })
  test_that("fast search (CIK)", {
    res <- variable_insurance_fast_search("0000891190")
    expect_is(res, "data.frame")

    expect_length(res, 12)
    expect_equal(nrow(res), 17)
    expect_length(unique(res$class_id), 17)

    expect_true(all(res$cik == "0000891190"))

    test.row <- res[6, ]
    expect_equal(test.row$class_id, "C000092042")
    expect_equal(test.row$class_name, "Institutional Shares")
    expect_equal(test.row$cik, "0000891190")
  })
})
