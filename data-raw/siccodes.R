library(xml2)

base <- "https://www.osha.gov/pls/imis/sic_manual.html"

doc <- read_html(base)

division_xpath <- "body/div[@id = 'wrapper']
                   /div[@id = 'maincontain']/div
                   //a[starts-with(@title, 'Division')]"

major_xpath <- "following::ul[1]/li/a"
group_xpath <- "body/div[@id = 'wrapper']
                /div[@id = 'maincontain']/div/strong"
industry_xpath <- "following::ul[1]/li"

divisions <- xml_find_all(doc, division_xpath)

siccodes <- as.data.frame(do.call(rbind, lapply(divisions, function(division) {
  div_title <- xml_text(xml_find_first(division, "@title"))
  div_letter <- substr(div_title, 10, 10)
  div_name <- trimws(substr(div_title, 13, nchar(div_title)))
  majors <- xml_find_all(division, major_xpath)
  as.data.frame(do.call(rbind, lapply(majors, function(major) {
    major_title <- xml_text(xml_find_first(major, "@title"))
    major_id <- substr(major_title, 13, 14)
    major_name <- trimws(substr(major_title, 17, nchar(major_title)))
    major_href <- url_absolute(xml_text(xml_find_first(major, "@href")),
                               xml_url(doc))
    major_doc <- read_html(major_href)
    groups <- xml_find_all(major_doc, group_xpath)
    as.data.frame(do.call(rbind, lapply(groups, function(group) {
      group_title <- xml_text(group)
      group_id <- substr(group_title, 16, 18)
      group_name <- trimws(substr(group_title, 21, nchar(group_title)))
      industries <- xml_find_all(group, industry_xpath)
      as.data.frame(do.call(rbind, lapply(industries, function(ind) {
               data.frame(
                 sic = trimws(xml_text(xml_find_first(ind, "text()[1]"))),
                 industry = xml_text(xml_find_first(ind, "a")),
                 division_id = div_letter,
                 division = div_name,
                 major = major_name,
                 group = group_name)
                               })))
    })))
  })))
})))

save(siccodes, file = "data/siccodes.rdata")
