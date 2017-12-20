#' Wide range of formats. This covers... some.
#' https://www.sec.gov/Archives/edgar/data/766285/000076628517000008/amana-nq20170228.htm
#' https://www.sec.gov/Archives/edgar/data/814679/000119312517185481/d313989dnq.htm
#' https://www.sec.gov/Archives/edgar/data/891190/000093247117004701/admiral_final.htm
#` @noRd
# parse_form_nq <- function (x) { }
# different types of tables: check for type, use that to run appropriate parse
# e.g. the 2nd example uses tables w/ 13 columns - can do something like this:

# xml_find_all(doc,'//div/table[count(*[1]/td) = 13]/tr')
