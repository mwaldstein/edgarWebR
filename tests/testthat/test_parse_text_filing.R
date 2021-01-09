context("running parse_text_filing")

with_mock_api({
  test_that("Ford 10-K", {
    href <-
      "https://www.sec.gov/Archives/edgar/data/37996/000003799602000015/v7.txt"
    res <- parse_text_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 1039)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res$item.name)), 17)
    expect_length(grep("<PAGE>", res$text), 0)
    expect_length(grep("<TEXT>", res$text), 0)
    expect_length(grep("</TEXT>", res$text), 0)
  })
  test_that("PERKINELMER 10-K", {
    href <-
      "https://www.sec.gov/Archives/edgar/data/31791/000095013501000920/b38210pee10-k405.txt"
    res <- parse_text_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 789)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res$item.name)), 15)
    expect_length(grep("<PAGE>", res$text), 0)
    expect_length(grep("<TEXT>", res$text), 0)
    expect_length(grep("</TEXT>", res$text), 0)
  })
  test_that("WMX Technologies", {
    skip_on_cran()
    #href <- "https://www.sec.gov/Archives/edgar/data/104938/0000950131-94-000440.txt"
    submission_file <- file.path("..", "testdata", "dev", "0000950131-94-000440.txt")
    skip_if_not(file.exists(submission_file),
                message = paste0("Dev test file ", submission_file, " does not exist - SKIP"))
    submission <- parse_submission(submission_file)
    expect_equal(nrow(submission), 8)
    doc <- submission[submission$TYPE == "10-K", "TEXT"]
    expect_equal(nchar(doc), 220403)
    res <- parse_text_filing(doc)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 463)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res$item.name)), 15)
    expect_equal(nrow(res[startsWith(res$item.name, "ITEM 7."), ]), 2)
    expect_length(grep("<PAGE>", res$text), 0)
    expect_length(grep("<TEXT>", res$text), 0)
    expect_length(grep("</TEXT>", res$text), 0)
  })
})
