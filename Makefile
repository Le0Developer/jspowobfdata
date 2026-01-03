SKEWC ?= npx skewc
SKEW_EXTRA_OPTIONS ?=
SKEW_OPTIONS ?= --release $(SKEW_EXTRA_OPTIONS)
TERSER ?= npx terser
SWC ?= npx swc
GZIP ?= gzip --best -k
BROTLI ?= brotli -Z

FILES = $(wildcard src/*.sk src/**/*.sk)

.PHONY: all default build build-all minify copy dist

default: build minify copy dist
all: build-all minify

build:
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/main.js --define:BTARGET=MAIN $(FILES)
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/page.js --define:BTARGET=PAGE $(FILES)

build-all: build
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/weblib.js --define:BTARGET=WEBLIB $(FILES)


minify:
	for file in `ls dist`; do $(SWC) dist/$$file -o dist/$$file; done
	for file in `ls dist`; do $(TERSER) dist/$$file -o dist/$$file --compress --mangle; done

copy:
	cp dist/page.js docs/script.js
	cp dist/main.js docs/dist/script.min.js

dist:
	rm docs/dist/script.min.js.gz || true
	rm docs/dist/script.min.js.br || true
	$(GZIP) docs/dist/script.min.js
	$(BROTLI) docs/dist/script.min.js
