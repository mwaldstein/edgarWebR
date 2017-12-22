# Test helper for mock_api
library(httptest)

httptest::.mockPaths("../cache")

# Test if mocks have been created
ewr_has_mocks <- TRUE

ewr_mock_bypass <- Sys.getenv("MOCK_BYPASS")

if (ewr_mock_bypass == "capture") {
  message("Capturing mocks...")
  with_mock_API <- function(f) {
    capture_requests(f, verbose = T)
  }
} else if (ewr_mock_bypass == "true" | !ewr_has_mocks) {
  message("Bypassing mocks...")
  with_mock_API <- force
}

# override buildMockUrl to shorten paths
# buildMockURL may not be locked in some circumstances, so try but fail quietly
try({
  unlockBinding("buildMockURL", environment(httptest::buildMockURL))
  },
  silent = FALSE)

buildMockURL.orig <- httptest::buildMockURL
buildMockURL.new <- function(req, method = "GET") {
  path <- buildMockURL.orig(req, method = method)

  # everything is on the sec, so drop it
  path <- gsub("^www.sec.gov/", "", path)

  # We don't branch under Archives, so simplify that part of the path
  path <- gsub("^Archives/edgar/", "", path)

  path
}

# Unsure why this change has happened, but this is known working...
assign("buildMockURL",
       buildMockURL.new,
       envir = environment(httptest::buildMockURL))
assign("buildMockURL", buildMockURL.new)
