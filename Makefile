SKEWC ?= npx skewc
SKEW_OPTIONS ?= --release
TERSER ?= npx terser
SWC ?= npx swc
GZIP ?= gzip --best -k
BROTLI ?= brotli -Z

FILES = $(wildcard src/*.sk src/**/*.sk)

.PHONY: build minify dist

all: build minify dist

build:
	$(SKEWC) $(SKEW_OPTIONS) --output-file=script.js --define:BTARGET=MAIN $(FILES)
	$(SKEWC) $(SKEW_OPTIONS) --output-file=docs/script.js --define:BTARGET=PAGE $(FILES)

minify:
	$(SWC) script.js -o script.js
	$(TERSER) script.js -o script.js --compress --mangle

dist:
	rm -rf docs/dist
	mkdir -p docs/dist
	cp script.js docs/dist/script.min.js
	$(GZIP) docs/dist/script.min.js
	$(BROTLI) docs/dist/script.min.js
