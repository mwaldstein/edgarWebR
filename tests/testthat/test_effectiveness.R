context("running effectiveness")

with_mock_api({
  test_that("running ", {
    res <- effectiveness()
    expect_length(res, 8)
  })
})
