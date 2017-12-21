context("running filing_documents")

with_mock_API({
  test_that("Basics (type 4)", {
    href <- "https://www.sec.gov/Archives/edgar/data/1333712/000156218017002633/0001562180-17-002633-index.htm"
    res <- filing_documents(href)
    expect_is(res, "data.frame")
    expect_length(res, 6)
    expect_equal(nrow(res), 3)

    # A couple of spot checks.
    # TODO: do a larger dump/load
    expect_equal(res$seq[1], 1)
    expect_equal(res$seq[2], 1)
    expect_equal(res$description[1], "PRIMARY DOCUMENT")
    expect_equal(res$description[3], "Complete submission text file")
    expect_equal(res$document[2], "primarydocument.xml")
    expect_equal(res$size[2], 4465)
    expect_equal(res$size[3], 5803)
  })
  test_that("Manages iXBRL", {
    href <- "https://www.sec.gov/Archives/edgar/data/920760/000162828017000327/0001628280-17-000327-index.htm"
    res <- filing_documents(href)
    expect_is(res, "data.frame")
    expect_length(res, 6)
    expect_equal(nrow(res), 16)

    # A couple of spot checks.
    # TODO: do a larger dump/load
    expect_equal(res$seq[1], 1)
    expect_equal(res$seq[2], 2)
    expect_equal(res$description[1], "10-K")
    expect_equal(res$description[3], "EXHIBIT 21")
    expect_equal(res$document[1], "len-20161130x10k.htm")
    expect_equal(res$document[2], "len-20161130x10kxexh1018.htm")
    expect_equal(res$size[2], 94292)
    expect_equal(res$size[3], 782273)

    expect_equal(res$href[1], "https://www.sec.gov/Archives/edgar/data/920760/000162828017000327/len-20161130x10k.htm")
  })
})
