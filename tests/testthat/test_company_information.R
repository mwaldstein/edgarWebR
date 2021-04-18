context("running company_information")

with_mock_api({
test_that("running ", {
            expect_error(company_information("BAD"))
            res <- company_information("EA")
            expect_is(res, "data.frame")

            expect_length(res, 19)
            expect_length(rownames(res), 1)

            expect_equal(res$name, "ELECTRONIC ARTS INC.")
})
})
