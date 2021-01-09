context("running filing_filers")

# The XPath for filing_filers is particularly complex, so it is particularly
# important to test a wide range of values

with_mock_api({
  test_that("Basics (type 4)", {
    href <- "https://www.sec.gov/Archives/edgar/data/1333712/000156218017002633/0001562180-17-002633-index.htm"
    res <- filing_filers(href)
    expect_is(res, "data.frame")
    expect_length(res, 21)
    expect_equal(nrow(res), 2)

    # A couple of spot checks.
    # TODO: do a larger dump/load
    expect_equal(res$business_address_1[1], "1 NEW ORCHARD ROAD")
    expect_equal(res$mailing_address_2[2], "294 ROUTE 100")
    expect_equal(res$company_name[1], "INTERNATIONAL BUSINESS MACHINES CORP")
    expect_equal(res$company_name[2], "Rometty Virginia M")

    expect_equal(res$company_cik[1], "0000051143")
    expect_equal(res$company_cik[2], "0001333712")

    expect_equal(res$company_irs_number[1], "130871985")
    expect_true(is.na(res$company_irs_number[2]))

    expect_true(is.na(res$file_number[1]))
    expect_equal(res$file_number[2], "001-02360")

    expect_true(is.na(res$film_number[1]))
    expect_equal(res$film_number[2], "171017664")

    expect_equal(res$sic_code[1], "3570")
    expect_true(is.na(res$sic_code[2]))
  })
})
