all: clean doc build
.PHONY: doc clean

# build package documentation
doc:
	Rscript -e 'devtools::document()'

test:
	Rscript -e 'devtools::test()'

build:
	Rscript -e 'devtools::build()'

clean:

cran_check: doc build
	cd ..;R CMD check --as-cran edgarWebR_0.0.1.tar.gz
