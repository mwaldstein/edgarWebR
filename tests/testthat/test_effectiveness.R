context("running effectiveness")

with_mock_API({
  test_that("running ", {
    res <- effectiveness()
    expect_length(res, 8)
  })
})
