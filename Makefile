all: clean doc build
.PHONY: doc clean build vignettes check

# build package documentation
doc:
	Rscript -e 'devtools::document()'

test:
	Rscript -e 'devtools::test()'

build: doc
	Rscript -e 'devtools::build()'

vignettes:
	Rscript -e 'devtools::build_vignettes()'

clean:
	-rm -f ../edgarWebR_*.tar.gz

cran_check: clean doc build
	cd ..;R CMD check --as-cran edgarWebR_*.tar.gz

install:
	Rscript -e 'devtools::install()'

check: clean build
	cd ..;R CMD check edgarWebR_*.tar.gz
