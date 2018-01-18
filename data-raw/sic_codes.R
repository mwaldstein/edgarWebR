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

sic_codes <- as.data.frame(do.call(rbind, lapply(divisions, function(division) {
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
                 group = group_name, stringsAsFactors = F)
                               })))
    })))
  })))
})), stringsAsFactors = F)


## Create SEC style sic overall codes
# Majors
majors <- data.frame(sic = paste0(substr(sic_codes$sic, 1, 2), "00"),
                     industry = sic_codes$major,
                     major = sic_codes$major,
                     group = sic_codes$major,
                     division = sic_codes$division,
                     division_id = sic_codes$division_id,
                     stringsAsFactors = F)
majors <- unique(majors)
# SEC drops leading 0's
majors$sic[startsWith(majors$sic, "0")] <-
  substr(majors$sic[startsWith(majors$sic, "0")], 2,4)
groups <- data.frame(sic = paste0(substr(sic_codes$sic, 1, 3), "0"),
                     industry = sic_codes$group,
                     major = sic_codes$major,
                     group = sic_codes$group,
                     division = sic_codes$division,
                     division_id = sic_codes$division_id,
                     stringsAsFactors = F)
groups <- unique(groups)
sic_codes <- rbind(sic_codes, majors, groups)

sec_sic_href <- "https://www.sec.gov/info/edgar/siccodes.htm"
doc <- xml2::read_html(sec_sic_href)
sec_sic <- data.frame(sic = xml_text(xml_find_all(doc, "//table/tr[count(td) = 4]/td[1]")),
                      ad = xml_text(xml_find_all(doc, "//table/tr[count(td) = 4]/td[2]")),
                      industry = xml_text(xml_find_all(doc, "//table/tr[count(td) = 4]/td[4]")),
                      stringsAsFactors = F)
sec_sic <- sec_sic[2:nrow(sec_sic),]
sec_sic <- sec_sic[!(sec_sic$sic %in% sic_codes$sic), ]

sec_sic$major_code <- paste0(substr(sec_sic$sic, 1, 2), "00")
sec_sic$group_code <- paste0(substr(sec_sic$sic, 1, 3), "0")
sec_sic <- merge(sec_sic, sic_codes[, c("sic", "division_id", "division", "major")],
                 by.x = "major_code", by.y = "sic", all.x = T)
sec_sic <- merge(sec_sic, sic_codes[, c("sic", "group")],
                 by.x = "group_code", by.y = "sic", all.x = T)
# not all groups in SEC exist, populate w/ industry as placeholder
sec_sic$group[is.na(sec_sic$group)] <- sec_sic$industry[is.na(sec_sic$group)]
sec_sic[, c("major_code", "group_code", "ad")] <- NULL

sic_codes <- rbind(sec_sic, sic_codes)

save(sic_codes, file = "data/sic_codes.rdata")
