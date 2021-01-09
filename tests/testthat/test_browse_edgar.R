context("running browse_edgar")

with_mock_api({
  test_that("running ", {
    expect_error(browse_edgar("EAR"),
                 "Could not find company: EAR")
    expect_s3_class(browse_edgar("EA"), "xml_node")
  })
})
