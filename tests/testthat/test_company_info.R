context("running company_info")

test_that("running ", {
            expect_error(company_info("EAR"))
            res <- company_info("EA")
            expect_is(res, "data.frame")

            expect_length(res, 16)
            expect_length(rownames(res), 1)

            expect_equal(res$name, "ELECTRONIC ARTS INC.")
})
