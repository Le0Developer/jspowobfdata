SKEWC ?= npx skewc
SKEW_EXTRA_OPTIONS ?=
SKEW_OPTIONS ?= --release $(SKEW_EXTRA_OPTIONS)
TERSER ?= npx terser
SWC ?= npx swc
GZIP ?= gzip --best -k
BROTLI ?= brotli -Z
FILESIZE ?= stat --format=%s
MODERN ?= 0

ifeq ($(MODERN), 1)
	SKEW_OPTIONS += --define:NATIVE_BASE64=true
endif

FILES = $(wildcard src/*.sk src/**/*.sk)

.PHONY: all default build build-all minify compr copy rust-wasm zig-wasm wasm

default: build minify copy compr
all: build-all minify

build:
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/main.js --define:BTARGET=MAIN $(FILES)
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/page.js --define:BTARGET=PAGE $(FILES)
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/speedtest.js --define:BTARGET=SPEEDTEST $(FILES)

build-all: build
	$(SKEWC) $(SKEW_OPTIONS) --output-file=dist/weblib.js --define:BTARGET=WEBLIB $(FILES)

minify:
	for file in `ls dist`; do $(SWC) dist/$$file -o dist/$$file; done
	for file in `ls dist`; do $(TERSER) dist/$$file -o dist/$$file --compress --mangle; done

copy:
	cp dist/page.js docs/script.js
	cp dist/main.js docs/dist/script.min.js
	cp dist/speedtest.js docs/speedtest.js

compr:
	rm dist/main.js.gz || true
	rm dist/main.js.br || true
	$(GZIP) dist/main.js
	$(BROTLI) dist/main.js

	@echo ""
	@echo "| Minified | Gzipped | Brotli |"
	@echo "| -------- | ------- | ------ |"
	@echo "| $$($(FILESIZE) dist/main.js) B | $$($(FILESIZE) dist/main.js.gz) B | $$($(FILESIZE) dist/main.js.br) B |"
	@echo ""

rust-wasm:
	cd rust-wasm; cargo build --release
	cp rust-wasm/target/wasm32-unknown-unknown/release/rust_wasm.wasm dist/rust_wasm.wasm

	echo "Generated Rust WASM size: $$($(FILESIZE) dist/rust_wasm.wasm) B"

	printf 'namespace decrypt.wasm {\n\tvar WASM_RUST = "%s"\n}\n' "$$(base64 -i dist/rust_wasm.wasm | tr -d '\n')" > src/core/rust_wasm_data.sk

zig-wasm:
	cd zig-wasm; zig build
	cp zig-wasm/zig-out/bin/wasm.wasm dist/zig_wasm.wasm

	echo "Generated Zig WASM size: $$($(FILESIZE) dist/zig_wasm.wasm) B"

	printf 'namespace decrypt.wasm {\n\tvar WASM_ZIG = "%s"\n}\n' "$$(base64 -i dist/zig_wasm.wasm | tr -d '\n')" > src/core/zig_wasm_data.sk

wasm: rust-wasm zig-wasm
