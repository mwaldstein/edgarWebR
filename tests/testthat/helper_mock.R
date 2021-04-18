# Test helper for mock_api
library(httptest)

httptest::.mockPaths("../cache")

# Test if mocks have been created
ewr_has_mocks <- TRUE

ewr_mock_bypass <- Sys.getenv("MOCK_BYPASS")

# For whatever reason, devtools::test can't find the redactor...
redactor <- system.file("inst", "httptest", "redact.R", package = "edgarWebR")
requester <- system.file("inst", "httptest", "request.R", package = "edgarWebR")
# Because we may now be running installed, if they don't exist, load
# directly...
if (!nchar(redactor) || !nchar(requester)) {
  redactor <- system.file("httptest", "redact.R", package = "edgarWebR")
  requester <- system.file("httptest", "request.R", package = "edgarWebR")
}
# Now we set options or fail
if (nchar(redactor) && nchar(requester)) {
  options(
          httptest.redactor = source(redactor)$value,
          httptest.requester = source(requester)$value
          )
} else {
  stop("Could not load redactor/requester")
}

if (ewr_mock_bypass == "capture") {
  message("Capturing mocks...")
  options(httptest.verbose = TRUE)
  with_mock_api <- function(f) {
    httptest::capture_requests(f)
  }
} else if (ewr_mock_bypass == "true" | !ewr_has_mocks) {
  message("Bypassing mocks...")
  with_mock_api <- force
}
