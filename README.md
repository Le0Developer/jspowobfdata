# jspowobfdata

JavaScript Proof Of Work Obfuscated Data.

This project provides a way to obfuscate data using a proof-of-work mechanism in
JavaScript. The obfuscated data can only be deobfuscated by solving a
computational puzzle, ensuring that the data is protected until the
proof-of-work is completed.

This is useful for scenarios where you want to hide information from casual bots
or automated systems, requiring them to expend computational effort before
accessing the data (for example, contact information on a webpage).

## Usage

Use the website to obfuscate your data:
https://le0developer.github.io/jspowobfdata/index.html

## Compatibility

The script used at runtime to deobfuscate is approximately:

| Minified | Gzipped | Brotli |
| -------- | ------- | ------ |
| 1258 B   | 705 B   | 607 B  |

It works in all modern browsers that support the
[Web Crypto API](https://caniuse.com/mdn-api_subtlecrypto) (Widely available
since 2017).

## Modern build

If you can spare some extra bytes and want better performance, you can use the
modern build that uses WebAssembly and Web Workers. This build is around:

| Minified | Gzipped | Brotli |
| -------- | ------- | ------ |
| 16947 B  | 7423 B  | 6461 B |

To use the modern build, include the `MODERN=1` flag when building the library
with `make`. The WASM implementation is ~5-6x faster than the pure SubtleCrypto
implementation.

If WASM or Workers are not supported, it will gracefully fall back to the pure
SubtleCrypto implementation (however without yielding to the main event loop due
to build flags).

## Animation

The `aria-busy` attribute is used to indicate the deobfuscation process is
ongoing. This allows you to add CSS animations during the proof-of-work phase.

We use such an animation (provided by [Pico.css](https://picocss.com/) ) on our
[demo page](https://le0developer.github.io/jspowobfdata/demo.html).

## Details

The obfuscation process involves the following steps:

1. Choose a key space (in bits) that determines the difficulty of the
   proof-of-work.

2. Generate a 32-byte AES-GCM key and a random nonce.

3. Encrypt the data using AES-GCM with the generated key and nonce.

4. Blank out N bits of the key to create a puzzle. The number of bits to blank
   is determined by the chosen key space.

5. Package the obfuscated data, nonce, and puzzle.

## Extra libraries

There are some extra libraries available in this repo, but you need to clone and
build them yourself using `make all`. They will be in the `dist/` folder after
building.

- `main.js` - The main runtime script to deobfuscate data in the browser. (see
  table above for size)
- `page.js` - The runtime script for the demo page. Almost 4kb due to UI
  handling, generation and speedtest. You shouldn't need to ever use this.
- `weblib.js` - This has the runtime logic like `main.js`, but it only exposes a
  minimal Javascript API and doesn't interact with the DOM by default. This
  makes it a further ~300 bytes smaller than `main.js`. By default it exports as
  a global `jsobfpow` function, but you can change that with build time flags.
  See `src/bundles/weblib.sk` for details.

## References

This is inspired by
[Altcha's Obfuscating Data](https://altcha.org/docs/v2/obfuscation/) feature,
however this implementation has a few key differences:

- No branding
- Small footprint (>25 times less JavaScript shipped to the client)

## Contributing

I consider this project in its current form to be feature complete.

Measurable improvements (e.g. runtime code size) will be welcome.
