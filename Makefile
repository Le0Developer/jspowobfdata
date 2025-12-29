SKEWC ?= npx skewc
SKEW_OPTIONS ?= --release
TERSER ?= npx terser
SWC ?= npx swc
FILES ?= src/*.sk src/**/*.sk
GZIP ?= gzip --best -k
BROTLI ?= brotli -Z

.PHONY: build minify dist

all: build minify dist

build:
	$(SKEWC) $(SKEW_OPTIONS) --output-file=page/script.js --define:IS_WEBPAGE=true $(FILES)
	$(SKEWC) $(SKEW_OPTIONS) --output-file=script.js $(FILES)

minify:
	$(SWC) script.js -o script.js
	$(TERSER) script.js -o script.js --compress --mangle

dist:
	rm -rf page/dist
	mkdir -p page/dist
	cp script.js page/dist/script.min.js
	$(GZIP) page/dist/script.min.js
	$(BROTLI) page/dist/script.min.js