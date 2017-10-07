context("running parse_submission")

# The XPath for filing_filers is particularly complex, so it is particularly
# important to test a wide range of values

with_mock_API({
  test_that("Basics (type 4)", {
    href <- "https://www.sec.gov/Archives/edgar/data/37996/000003799617000084/0000037996-17-000084.txt"
    res <- parse_submission(href)
    expect_is(res, "data.frame")
    expect_length(res, 5)
    expect_equal(nrow(res), 7)

    # A couple of spot checks.
    expect_equal(res$DESCRIPTION[1], "8-K")
    expect_equal(res$SEQUENCE[1], "1")
    expect_equal(res$TYPE[1], "8-K")
    expect_equal(res$FILENAME[1], "ceostrategicupdate8-k.htm")
    expect_equal(nchar(res$TEXT[1]), 29683)

    expect_equal(res$DESCRIPTION[2], "EXHIBIT 99")
    expect_equal(res$SEQUENCE[2], "2")
    expect_equal(res$TYPE[2], "EX-99")
    expect_equal(res$FILENAME[2], "exhibit99ceostrategicupd.htm")
    expect_equal(nchar(res$TEXT[2]), 17179)

    expect_true(is.na(res$DESCRIPTION[7]))
    expect_equal(res$SEQUENCE[7], "7")
    expect_equal(res$TYPE[7], "GRAPHIC")
    expect_equal(res$FILENAME[7], "exhibit99ceostrategicupd005.jpg")
    expect_equal(nchar(res$TEXT[7]), 93499)
  })
})
