context("running fund_search")

test_that("running", {
            res <- fund_search("precious metals")
            expect_is(res, "data.frame")

            expect_length(res, 12)
            expect_equal(nrow(res), 80)
            expect_length(unique(res$class_id), 80)

            test.row <- res[75, ]
            expect_equal(test.row$class_id, "C000008009")
            expect_equal(test.row$class_name, "Investor Shares")
            expect_equal(test.row$cik, "0000734383")
})
