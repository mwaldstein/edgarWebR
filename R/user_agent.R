# User Agent for working with EDGAR
#
# We do this to handle edgar-specific error messages and ensure we set the UA
# and similar configuration properties once

edgar_agent <- Sys.getenv(
  "EDGARWEBR_USER_AGENT",
  unset = "edgarWebR (https://mwaldstein.github.io/edgarWebR/)"
)
ua <- httr::user_agent(edgar_agent)

edgar_GET <- function(path) {
  res <- httr::GET(path, ua)
  check_result(res)
  return(res)
}

edgar_POST <- function(href, body, encode = "json") {
  # res <- httr::POST(href, body = body, encode = encode, httr::verbose())
  res <- httr::POST(href, body = body, encode = encode)
  check_result(res)
  return(res)
}

check_result <- function(res) {
  if (httr::status_code(res) == 200) {
    return()
  }
  text_content <- httr::content(res, "text")
  if (httr::status_code(res) == 403 && grepl("Undeclared Automated Tool", text_content, fixed = TRUE)) {
    stop(paste0(
      "EDGAR request blocked from Undeclared Automated Tool.\n",
      "Please visit https://www.sec.gov/developer for best practices.\n",
      "See https://mwaldstein.github.io/edgarWebR/index.html#ethical-use--fair-access for your responsibilities\n",
      "Consider also setting the environment variable 'EDGARWEBR_USER_AGENT",
    ))
  }
  stop(
       sprintf(
               "EDGAR request failed [%s]\n%s\n<%s>",
               httr::status_code(res),
               httr::content(res, "text"),
               res.url
               )
       )
}
