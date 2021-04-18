#' SEC Filing Information
#'
#' The SEC generates a html page as an index for every filing it receives containing
#' all the meta-information about the filing.
#'
#' Information returned:
#' \itemize{
#'  \item type
#'  \item description
#'  \item accession_number
#'  \item filing_date
#'  \item accepted_date
#'  \item documents
#'  \item period_date
#'  \item changed_date
#'  \item effective_date
#'  \item filing_bytes
#' }
#' Not all details are valid for all filings, but the column will always be present
#'
#' If you know you're going to want all the details of a filing, including documents
#' funds and filers, look at `filing_details`
#'
#' @param x URL or xml_document for a SEC filing index page
#'
#' @return A dataframe with all the parsed meta-info on the filing
#'
#' @examples
#' \donttest{
#' # Typically you'd get the URL from one of the search functions
#' x <- paste0("https://www.sec.gov/Archives/edgar/data/",
#'             "933691/000119312517247698/0001193125-17-247698-index.htm")
#' try(filing_information(x))
#' }
#' @export
filing_information <- function(x) {
  UseMethod("filing_information")
}

#' @rdname filing_information
#' @export
filing_information.character <- function(x) {
  filing_information(charToDoc(x))
}

#' @rdname filing_information
#' @export
filing_information.xml_node <- function(x) {
  info_xpath <- "."
  info_pieces <- list(
    "type" = "substring-after(//div[@id='formName']/strong, 'Form ')",
    "description" = "substring-after(//div[@id='formName']/text()[2], ' - ')",
    "accession_number" = "//div[@id='secNum']/text()[2]",
    "filing_date" = "//div[@class='infoHead'][. = 'Filing Date']/following-sibling::div[1]",
    "accepted_date" = "//div[@class='infoHead'][. = 'Accepted']/following-sibling::div[1]",
    "documents" = "//div[@class='infoHead'][. = 'Documents']/following-sibling::div[1]",
    "period_date" = "//div[@class='infoHead'][. = 'Period of Report']/following-sibling::div[1]",
    "changed_date" = "//div[@class='infoHead'][. = 'Filing Date Changed']/following-sibling::div[1]",
    "effective_date" = "//div[@class='infoHead'][. = 'Effectiveness Date']/following-sibling::div[1]",
    "bytes" = "//td[@scope='row'][. = 'Complete submission text file']/following-sibling::td[3]"
    )
  info_trim <- c("description", "accession_number")

  info <- map_xml(x, info_xpath, info_pieces, trim = info_trim, integers = c("bytes", "documents"))

  return(info)
}
