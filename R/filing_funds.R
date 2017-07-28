#' SEC Filing Funds
#'
#' @param href URL to a SEC filing index page
#' 
#' @return A dataframe with all the funds associated with a given filing
#'
#' @importFrom xml2 read_html
#'
#' @export
filing_funds <- function(href) {
  data <- xml2::read_html(href)

  entries_xpath <- "//td[@class='classContract']"

  #entries <- xml2::xml_find_all(data, entries_xpath)

  info_pieces <- list(
    "cik" = "preceding::td[@class='CIKname'][descendant::a][1]/a/text()",
    "cik_href" = "preceding::td[@class='CIKname'][descendant::a][1]/a/@href",
    "series" = "preceding::td[@class='seriesName'][1]/a/text()",
    "series_href" = "preceding::td[@class='seriesName'][1]/a/@href",
    "series_name" = "preceding::td[@class='seriesName'][1]/following-sibling::td[2]/text()",
    "contract" = "a/text()",
    "contract_href" = "a/@href",
    "contract_name" = "following-sibling::td[2]/text()",
    "ticker" = "following-sibling::td[3]/text()"
    )

  res <- map_xml(data, entries_xpath, info_pieces)

  return(res)
}
