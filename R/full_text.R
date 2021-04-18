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
#'@param location Filter based on company's location
#'@param incorporated_location boolean to use location of incorporation rather
#'       than location of HQ
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
    query[["q"]] <- jsonlite::unbox(q)
  }
  if (from != "" && to != "") {
    query[["startdt"]] <- jsonlite::unbox(format_date(from))
    query[["enddt"]] <- jsonlite::unbox(format_date(to))
  }
  if (any(type != "")) {
    query[["category"]] <- jsonlite::unbox("custom")
    query[["forms"]] <- map_form(type)
  }
  if (page != "" && page != 1) {
    query[["page"]] <- jsonlite::unbox(page)
    query[["from"]] <- jsonlite::unbox(page * 100)
  }
  if ( name != "" && cik != "") {
    stop("Cannot perform full search with both a name and cik")
  }
  if (name != "" || cik != "") {
    query[["entityName"]] <- jsonlite::unbox(ifelse(name == "", cik, name))
  }
  if (location != "") {
    if (incorporated_location) {
      query[["locationType"]] <- "incorporated"
    }
    query[["locationCode"]] <- jsonlite::unbox(location)
    query[["locationCodes"]] <- location
  }

  # stop(jsonlite::toJSON(query))
  res <- edgar_POST(href, body = query, encode = "json")
  if (res$status != "200") {
    stop(paste0("Unable to reach the SEC full text search endpoint (",
                href,
                ")"))
  }

  json_res <- httr::content(res, as = "parsed")
  hits <- json_res$hits$hits
  if (length(hits) == 0) {
    return(list())
  }

  lRes <- lapply(hits, function (hit) {
                   nsic = length(hit[["_source"]]$sics)
                   ncik = length(hit[["_source"]]$ciks)
                   if (ncik == 0) {
                     # We often seen to end up w/out and ciks - don't worry
                     # about this row in that case...
                     return()
                   }

                   cik <- hit[["_source"]]$ciks[[length(hit[["_source"]]$ciks)]]
                   accession <- hit[["_source"]]$adsh
                   filename <- gsub("^.+:", "", hit[["_id"]])
                   root_form <- hit[["_source"]]$root_form
                   file_type <- hit[["_source"]]$file_type

                   list(
                        filing_date = hit[["_source"]]$file_date,
                        name = trimws(paste(hit[["_source"]]$root_form, ifelse(root_form == file_type, "", hit[["_source"]]$file_type))),
                        href = submission_file_href(cik, accession, filename),
                        company_name = gsub("\\s+\\(CIK.*$", "", hit[["_source"]]$display_names[[length(hit[["_source"]]$display_names)]]),
                        cik = cik,
                        sic = ifelse(nsic > 0,
                                     hit[["_source"]]$sics[[nsic]],
                                     NA),
                        content = ifelse(length(hit[["_source"]]$file_description) > 0, hit[["_source"]]$file_description, NA),
                        # parent_href = "",
                        parent_href = submission_index_href(cik, accession),
                        index_href = submission_index_href(cik, accession)
                        )
    })

  df_res <- data.frame(matrix(unlist(lRes), ncol = max(lengths(lRes)), byrow = TRUE), stringsAsFactors = FALSE)
  names(df_res) <- names(lRes[[which(lengths(lRes)>0)[1]]])

  df_res$filing_date <- as.POSIXct(df_res$filing_date,
                                   format = "%Y-%m-%d")
  return(df_res)
}

map_form <- function(form) {
  form <- sub("/", "", form)

  return(as.list(form))
}

format_date <- function(slash_date) {
  parts <- strsplit(slash_date, "/")[[1]]
  if (length(parts) != 3) {
    stop("Input dates must be int 'mm/dd/yyyy' format!")
  }
  return(paste0(parts[3], "-", parts[1], "-", parts[2]))
}
