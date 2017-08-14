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

all: clean doc build
.PHONY: doc clean build vignettes check

# build package documentation
doc: readme vignettes
	Rscript -e 'devtools::document()'

test:
	Rscript -e 'devtools::test()'

build: doc
	Rscript -e 'devtools::build()'

vignettes:
	Rscript -e 'devtools::build_vignettes()'

# Tidy, but keep everything in git
clean:
	$(RM) -r vignettes/*cache
	$(RM) -r vignettes/*files
	$(RM) -r vignettes/*figure
	$(RM) -r vignettes/*.md
	$(RM) -r docs/*cache
	$(RM) -r docs/articles/*cache

# Purge all generated files, leave only true source
dist-clean: clean
	$(RM) -r man
	$(RM) -r doc
	$(RM) README.md
	$(RM) -r inst

cran-check: clean doc build
	cd ..;R CMD check --as-cran edgarWebR_*.tar.gz

install:
	Rscript -e 'devtools::install()'

check: clean build
	cd ..;R CMD check edgarWebR_*.tar.gz

live-test:
	Rscript -e 'testthat::auto_test_package()'

coverage:
	Rscript -e 'covr::report(covr::package_coverage(), file="~/public_html/edgarWebR-cov.html", browse = FALSE)'

lint:
	Rscript -e 'lintr::lint_package()'

site: doc
	Rscript -e 'pkgdown::build_site()'

readme:
	Rscript -e 'rmarkdown::render("README.Rmd")'
