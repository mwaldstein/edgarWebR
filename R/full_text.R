#' SEC Full-Text Search
#'
#' Provides access to the SEC fillings
#' \href{https://www.sec.gov/edgar/search/}{full-text search tool}.
#'
#'@param q Search query. For details on special formatting, see the
#' \href{https://www.sec.gov/edgar/search/efts-faq.html}{FAQ}.
#'@param type Type of forms to search - e.g. '10-K'. Can also be a list of
#'        types - e.g. c("10-K", "10-Q")
#'@param reverse_order [DEP] If true, order by oldest first instead of newest first
#'@param count [DEP] Number of results to return - will always try to return
#'        100
#'@param page Which page of results to return
#'@param stemming [DEP] Search by base words(default) or exactly as entered
#'@param name Company name OR individual's name. Cannot be combined with `cik` or `sik`.
#'@param sic [DEP] Standard Industrial Classification of filer to search for. Cannot
#'        be combined with `cik` or `name`. Special options - 1: all, 0:
#'        Unspecified.
#'@param cik Company code to search. Cannot be combined with `name` or `sic`
#'@param from Start date. Must be in the form of `mm/dd/yyyy`. Must also
#'       specify `to`
#'@param to End date. Must be in the form of `mm/dd/yyyy`. Must also
#'       specify `from`
#'
#'@return A dataframe list of results including the following columns -
#'  \itemize{
#'    \item filing_date
#'    \item name
#'    \item href
#'    \item company_name
#'    \item cik
#'    \item sic
#'    \item content
#'    \item parent_href
#'    \item index_href
#'  }
#' @examples
#'\donttest{
#'## This can be very slow running
#' full_text('intel')
#'}
#'@export
full_text <- function(
    q = "*",
    type = "",
    reverse_order = FALSE,
    count = 100,
    page = 1,
    stemming = TRUE,
    name = "",
    cik = "",
    sic = "",
    from = "",
    to = "",
    location = "",
    incorporated_location = FALSE) {
  href <- "https://efts.sec.gov/LATEST/search-index"
  query <- list()
  if (q != "*" && q != "") {
    query["q"] <- jsonlite::unbox(q)
  }
  if (from != "" && to != "") {
    query["startdt"] <- jsonlite::unbox(format_date(from))
    query["enddt"] <- jsonlite::unbox(format_date(to))
  }
  if (type != "") {
    query["category"] <- jsonlite::unbox("custom")
    query["forms"] <- map_form(type)
  }
  if (page != "" && page != 1) {
    query["page"] <- jsonlite::unbox(page)
    query["from"] <- jsonlite::unbox(page * 100)
  }
  if ( name != "" && cik != "") {
    stop("Cannot perform full search with both a name and cik")
  }
  if (name != "" || cik != "") {
    query["entityName"] <- jsonlite::unbox(ifelse(name == "", cik, name))
  }
  if (location != "") {
    if (incorporated_location) {
      query["locationType"] <- "incorporated"
    }
    query["locationCode"] <- jsonlite::unbox(location)
    query["locationCodes"] <- location
  }

  res <- httr::POST(href, body = query, encode = "json")
  if (res$status != "200") {
    stop(paste0("Unable to reach the SEC full text search endpoint (",
                href,
                ")"))
  }

  json_res <- httr::content(res, as = "parsed")
  hits <- json_res$hits$hits
  lRes <- lapply(hits, function (hit) {
                   cik <- hit[["_source"]]$ciks[[length(hit[["_source"]]$ciks)]]
                   accession <- hit[["_source"]]$adsh
                   filename <- gsub("^.+:", "", hit[["_id"]])
                   parent_href <- submission_file_href(
                                                       cik,
                                                       accession,


                                                       )
                   list(
                        filing_date = hit[["_source"]]$file_date,
                        name = hit[["_source"]]$root_form,
                        href = submission_file_href(cik, accession, filename),
                        company_name = hit[["_source"]]$display_names[[length(hit[["_source"]]$display_names)]],
                        cik = cik,
                        sic = hit[["_source"]]$sics[[length(hit[["_source"]]$sics)]],
                        content = "",
                        # parent_href = "",
                        parent_href = submission_index_href(cik, accession),
                        index_href = submission_index_href(cik, accession)
                        )
    })

  df_res <- do.call(rbind.data.frame, lRes)
  df_res$filing_date <- as.POSIXct(df_res$filing_date,
                                   format = "%m/%d/%Y")
  return(df_res)

  # res <- map_xml(doc, entries_xpath,
  #                info_pieces, trim = trim_cols,
  #                date_format = "%m/%d/%Y")
}

map_form <- function(form) {
  form <- sub("/", "", form)

  return(form)
}

format_date <- function(slash_date) {
  parts <- strsplit(slash_date, "/")[[1]]
  if (length(parts) != 3) {
    stop("Input dates must be int 'mm/dd/yyyy' format!")
  }
  return(paste0(parts[3], "-", parts[1], "-", parts[2]))
}
