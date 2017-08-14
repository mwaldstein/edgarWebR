#' SEC Filing Funds
#'
#' @param x URL to a SEC filing index page
#' 
#' @return A dataframe with all the funds associated with a given filing
#'
#' @importFrom methods is
#' @examples
#' # Typically you'd get the URL from one of the search functions
#' x <- paste0("https://www.sec.gov/Archives/edgar/data/",
#'             "933691/000119312517247698/0001193125-17-247698-index.htm")
#' filing_funds(x)
#' @export
filing_funds <- function(x) {
  doc <- if (is(x,"xml_node")) { x } else { xml2::read_html(x) }

  entries_xpath <- "//td[@class='classContract']"

  info_pieces <- list(
    "cik" = "preceding::td[@class='CIKname']/a",
    "cik_href" = "preceding::td[@class='CIKname']/a/@href",
    "series" = "preceding::td[@class='seriesName'][1]/a",
    "series_href" = "preceding::td[@class='seriesName'][1]/a/@href",
    "series_name" = "preceding::td[@class='seriesName'][1]/following-sibling::td[2]/text()",
    "contract" = "a/text()",
    "contract_href" = "a/@href",
    "contract_name" = "following-sibling::td[2]/text()",
    "ticker" = "following-sibling::td[3]/text()"
    )

  res <- map_xml(doc, entries_xpath, info_pieces)

  return(res)
}
