context("running parse_filing")

# The XPath for filing_filers is particularly complex, so it is particularly
# important to test a wide range of values

with_mock_API({
  test_that("Basics (type 10-Q)", {
    href <- "https://www.sec.gov/Archives/edgar/data/712515/000071251517000010/ea12312016-q3fy1710qdoc.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 695)

    # A couple of spot checks.
    expect_equal(length(unique(res$part.name)), 3)
    expect_equal(length(unique(res$item.name)), 11)
    expect_equal(length(unique(res[startsWith(res$part.name, "PART I "),
                               "item.name"])), 5)
    expect_equal(length(unique(res[startsWith(res$part.name, "PART II "),
                               "item.name"])), 7)
  })
  test_that("Basics (type 10-Q - STX)", {
    href <- "https://www.sec.gov/Archives/edgar/data/1137789/000119312517148855/d381726d10q.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 500)

    # A couple of spot checks.
    expect_equal(length(unique(res$part.name)), 3)
    expect_equal(length(unique(res$item.name)), 12)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 5)
    expect_equal(length(unique(res[startsWith(res$part.name, "PART II"),
                               "item.name"])), 8)
  })
  test_that("Handles parsed docs", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/712515/000071251517000010/ea12312016-q3fy1710qdoc.htm"
    doc <- xml2::read_html(href)
    res <- parse_filing(href, strip = FALSE, include.raw = TRUE)
    expect_is(res, "data.frame")
    expect_length(res, 4)
    expect_equal(nrow(res), 1197)
  })
  test_that("Handles 8-K", {
    href <- "https://www.sec.gov/Archives/edgar/data/320193/000162828017000663/a8-kq1201712312016.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 35)
    expect_equal(length(unique(res$part.name)), 1)
    # This is failing because there are no parts, so it isn't pulling any items
    expect_equal(length(unique(res$item.name)), 3)
  })
  test_that("Handles 10-K (edgarx.com)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/38264/000100329716000907/forward10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(nrow(res), 541)
  })
  test_that("Handles 10-K (Ford)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/37996/000003799617000013/f1231201610-k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 23)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(nrow(res), 1675)
  })
  test_that("Handles 10-K (WLL)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/1255474/000125547417000005/wll-20161231x10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 22)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 7)
  })
  test_that("Handles 10-K (YUM)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/1041061/000104106109000077/form_10-k22309.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 7)
  })
  test_that("Handles 10-K (DELL)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/826083/000095013406005149/d33857e10vk.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 16)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 7)
  })
  test_that("Handles 10-K (Alcoa)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/4281/000119312516470162/d216801d10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 7)
  })
  test_that("Handles 10-K (Tenga)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/39899/000003989916000034/tgna-20151231x10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 20)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 7)
  })
  test_that("Handles 10-K (Pacific Corp)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/878560/000087856012000008/form10-k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART I",
                               "item.name"])), 7)
  })
  test_that("Handles 10-K (Macy's)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/794367/000079436713000092/m-02022013x10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 20)
    expect_equal(length(unique(res$part.name)), 4)
    expect_equal(length(unique(res[res$part.name == "PART II",
                               "item.name"])), 8)
  })
  test_that("Handles 10-K (Verizon)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/732712/000119312509036349/d10k.htm#tx90102_1"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART II",
                               "item.name"])), 9)
  })
  test_that("Handles 10-K (Vulcan)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/1396009/000139600916000044/vmc-20151231x10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART II",
                               "item.name"])), 9)
  })
  test_that("Handles 10-K (Vulcan v2)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/1396009/000119312513084128/d451546d10k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART II",
                               "item.name"])), 9)
  })
  test_that("Handles 10-K (Pacificorp v2)", {
    skip_on_cran() # Basics for CRAN are sufficiently tested...
    href <- "https://www.sec.gov/Archives/edgar/data/878560/000087856014000007/form10-k.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(length(unique(res$item.name)), 21)
    expect_equal(length(unique(res$part.name)), 5)
    expect_equal(length(unique(res[res$part.name == "PART II",
                               "item.name"])), 9)
  })
  test_that("Treats <br> as space", {
    href <- "https://www.sec.gov/Archives/edgar/data/1399855/000119312514363235/d778787d10q.htm"
    res <- parse_filing(href)
    tmp <- res[grepl('Weighted average exercise price', res$text,
                     ignore.case=F), ]
    expect_equal(nrow(tmp), 1)
  })
  test_that("Handles HTML wrapped text filling (", {
    href <- "https://www.sec.gov/Archives/edgar/data/1424844/000092290708000774/form10k_122308.htm"
    res <- parse_filing(href)
    expect_is(res, "data.frame")
    expect_length(res, 3)
    expect_equal(nrow(res), 796)
    expect_equal(length(unique(res$item.name)), 19)
    expect_equal(length(unique(res$part.name)), 4)
    expect_equal(length(unique(res[res$part.name == "PART II",
                               "item.name"])), 8)
  })
})
