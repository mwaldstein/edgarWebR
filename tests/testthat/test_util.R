context("running URL Utilities")

test_that("submission functions", {
  expect_equal(submission_index_href("0000712515", "0000712515-17-000090"),
               "https://www.sec.gov/Archives/edgar/data/712515/000071251517000090/0000712515-17-000090-index.htm")
  expect_equal(submission_href("0000712515", "0000712515-17-000090"),
               "https://www.sec.gov/Archives/edgar/data/712515/000071251517000090/0000712515-17-000090.txt")
  expect_equal(submission_file_href("0000712515", "0000712515-17-000090",
                                    "pressrelease-ueberroth.htm"),
               "https://www.sec.gov/Archives/edgar/data/712515/000071251517000090/pressrelease-ueberroth.htm")
})

test_that("company_href", {
  expect_equal(company_href("0000037912"),
               "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=0000037912&owner=exclude&hidefilings=0")
})
