#' SEC Filing Included Filers
#'
#' @param x URL to a SEC filing index page
#' 
#' @return A dataframe with all the filers in the filing along with their info
#'
#' @importFrom methods is
#' @examples
#' # Typically you'd get the URL from one of the search functions
#' x <- paste0("https://www.sec.gov/Archives/edgar/data/",
#'             "712515/000071251517000063/0000712515-17-000063-index.htm")
#' filing_filers(x)
#' @export
filing_filers <- function(x) {
  # We want to accept a pre-fetched document or possibly a sub-page node
  doc <- if (is(x, "xml_node")) { x } else { xml2::read_html(x) }

  entries_xpath <- "//div[@id='filerDiv']"

  # This gets really ugly thanks to some unstructured formatting
  info_pieces <- list(
    "mailing_address_1" = "div[@class='mailer'][contains(.,'Mailing Address')]/span[1]",
    "mailing_address_2" = "div[@class='mailer'][contains(.,'Mailing Address')]/span[2]",
    "mailing_address_3" = "div[@class='mailer'][contains(.,'Mailing Address')]/span[3]",
    "mailing_address_4" = "div[@class='mailer'][contains(.,'Mailing Address')]/span[4]",
    "business_address_1" = "div[@class='mailer'][contains(.,'Business Address')]/span[1]",
    "business_address_2" = "div[@class='mailer'][contains(.,'Business Address')]/span[2]",
    "business_address_3" = "div[@class='mailer'][contains(.,'Business Address')]/span[3]",
    "business_address_4" = "div[@class='mailer'][contains(.,'Business Address')]/span[4]",
    "company_name" = "substring-before(div[@class='companyInfo']/span[@class='companyName']/text()[1], ' (')",
    "company_cik" = "substring-before(div[@class='companyInfo']/span[@class='companyName']/a[contains(@href, 'browse-edgar')],' (')",
    "company_filings_href" = "div[@class='companyInfo']/span[@class='companyName']/a[contains(@href, 'browse-edgar')]/@href",
    "company_irs_number" = "div/p[@class='identInfo']/acronym[. = 'IRS No.']/following-sibling::strong[1]",
    "company_incorporation_state" = "div/p[@class='identInfo']/text()[contains(.,'Incorp')]/following-sibling::strong[1]",
    "company_fiscal_year_end" = "div/p[@class='identInfo']/text()[contains(.,'Year End')]/following-sibling::strong[1]",
    "filing_type" = "div/p[@class='identInfo']/text()[contains(.,'Type:')]/following-sibling::strong[1]",
    "filing_act" = "div/p[@class='identInfo']/text()[contains(.,'Act:')]/following-sibling::strong[1]",
    "file_number_href" = "div/p[@class='identInfo']/a[1]/@href",
    "file_number" = "div/p[@class='identInfo']/a[1]",
    "film_number" = "div/p[@class='identInfo']/text()[contains(.,'Film No.:')]/following-sibling::strong[1]",
    "sic_code" = "div/p[@class='identInfo']/b/a",
    "sic_href" = "div/p[@class='identInfo']/b/a/@href"
    )

  filer_trim <- c("company_name",
                 paste0("mailing_address_", seq(4)),
                 paste0("business_address_", seq(4)))

  res <- map_xml(doc, entries_xpath, info_pieces, trim = filer_trim)

  return(res)
}
