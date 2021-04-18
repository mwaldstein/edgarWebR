context("running browse_edgar")

with_mock_api({
  test_that("running ", {
    expect_error(browse_edgar("BAD"),
                 "Could not find company: BAD")
    expect_s3_class(browse_edgar("EA"), "xml_node")
  })
})
