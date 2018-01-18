#' SIC Codes
#'
#' SIC code table with structure.
#'
#' @format A data frame with 1005 rows and 6 variables:
#' \describe{
#'   \item{sic}{Standard Industrial Classification}
#'   \item{industry}{Name of industry}
#'   \item{division_id}{Letter code for the division}
#'   \item{division}{Name of the division}
#'   \item{major}{Name of the major group, identified by 1st 2 digits of the sic}
#'   \item{group}{Name of the group, identified by the 1st 3 digits of the sic}
#' }
#' @source \url{https://www.osha.gov/pls/imis/sic_manual.html}
#' @source \url{https://www.sec.gov/info/edgar/siccodes.htm}
"sic_codes"
