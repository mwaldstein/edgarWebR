PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename $(PWD))
TGZ     := $(PKGSRC)_$(PKGVERS).tar.gz
TGZVNR  := $(PKGSRC)_$(PKGVERS)-vignettes-not-rebuilt.tar.gz

# Specify the directory holding R binaries. To use an alternate R build (say a
# pre-prelease version) use `make RBIN=/path/to/other/R/` or `export RBIN=...`
# If no alternate bin folder is specified, the default is to use the folder
# containing the first instance of R on the PATH.
RBIN ?= $(shell dirname "`which R`")

all: doc build
.PHONY: doc clean build vignettes check revdep data

# build package documentation
doc:
	Rscript -e 'devtools::document()'

test:
	Rscript -e 'library(httptest); devtools::test()'

test-nocache:
	MOCK_BYPASS="true" EDGARWEBR_USER_AGENT="EDGARWebR Automated Tests" Rscript -e 'library(httptest); devtools::test()'

test-buildcache: test-cleancache
	MOCK_BYPASS="capture" EDGARWEBR_USER_AGENT="EDGARWebR Automated Tests" Rscript -e 'library(httptest); devtools::test()'

test-cleancache:
	${RM} -r tests/cache

build: doc
	Rscript -e 'devtools::build()'

doc-all: doc readme vignettes

vignettes:
	Rscript -e 'devtools::build_vignettes(clean = FALSE)'

live-vignettes:
	Rscript -e 'servr::rmdv2(dir="vignettes",port = 8080)'

vignettes-clean:
	${RM} -r vignettes/intro
	${RM} -r vignettes/parsing

vignettes-rebuild: vignettes-clean vignettes

# Tidy, but keep everything in git
clean:
	$(RM) -r vignettes/*cache
	$(RM) -r vignettes/*files
	$(RM) -r vignettes/*figure
	$(RM) -r vignettes/*.md
	$(RM) -r docs/*cache
	$(RM) -r docs/articles/*cache

# Purge all generated files, leave only true source
dist-clean: clean test-cleancache
	$(RM) -r man
	$(RM) -r doc
	$(RM) README.md
	$(RM) -r inst

install:
	Rscript -e 'devtools::install()'

check: build
	cd ..;R CMD check $(TGZ)

cran-check: doc build
	cd ..;R CMD check --as-cran $(TGZ)

live-test:
	Rscript -e 'library(httptest); testthat::auto_test_package()'

coverage:
	Rscript -e 'covr::report(covr::package_coverage(), file="~/public_html/edgarWebR-cov.html", browse = FALSE)'

lint:
	@echo "Make sure you're using lintr >= 1.0.1 (probably need to use github)"
	Rscript -e 'lintr::lint_package()'

site: doc-all
	Rscript -e 'pkgdown::build_site()'

readme:
	Rscript -e 'rmarkdown::render("README.Rmd")'

ubuntu-deps:
	apt-get install texlive-latex-base texlive-fonts-extra libharfbuzz-dev libfribidi-dev

revdep:
	cd revdep; Rscript check.R

data:
	Rscript data-raw/sic_codes.R
