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
| 1361 B   | 751 B   | 648 B  |

It works in all modern browsers that support the
[Web Crypto API](https://caniuse.com/mdn-api_subtlecrypto) (Widely available
since 2017).

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

## References

This is inspired by
[Altcha's Obfuscating Data](https://altcha.org/docs/v2/obfuscation/) feature,
however this implementation has a few key differences:

- No branding
- Small footprint (>25 times less JavaScript shipped to the client)

## Contributing

I consider this project in its current form to be feature complete.

Measurable improvements (e.g. runtime code size) will be welcome.
