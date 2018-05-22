context("running current_events")

with_mock_API({
  test_that("Basic Search", {
    res <- current_events(0, "10-K")

    expect_is(res, "data.frame")
    expect_length(res, 6)

    expect_true(!any(!startsWith(res$type, "10-K")))
  })
})
