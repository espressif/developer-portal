# Developer Portal

This project stores the files for the [Espressif Developer Portal][] website. GitHub Actions statically generate the website using Hugo and pushes it to a web server for online hosting.

[Espressif Developer Portal]: https://developer.espressif.com/

This doesn't works. See [this](./content/blog/2025/03/esp32-bluetooth-clearing-the-air/index.md#impat).

For details, see the page [at this link](https://google.com).

## Contribute and render locally

If you want to contribute to this project, it would be nice to see the rendered version. The website can be easily rendered on your local machine using the following steps:

1. Clone this repository using `git clone --recursive --shallow-submodules`.
2. Install Hugo following the [instructions](https://gohugo.io/installation/).
3. In the project folder, run `hugo server` and open the provided local web address, usually `http://localhost:1313/`.

See also the Contribution Guide articles:

- [Contribution workflow](./content/pages/contribution-guide/contrib-workflow/index.md)
- [Writing content](./content/pages/contribution-guide/writing-content/index.md)

## Test Vale style

---

Rule `Espressif-devportal.HeadingSentenceCase`

#### Use Sentence Style Capitalization

#### Exceptions for capitalization can be added like espressif

---

Rules `Espressif-devportal.ListEndPunctuation` and `Espressif-devportal.ListMixedType`

Simple bullet list:

- Item 1
- Item 2.

Multi-level list:

1. Item 1:
2. Item 2
  - Item 1.
  - Item 2

Bullets and numbers at the same level:

1. Item 1
- Item 2

---

Rule `Espressif-devportal.NonStandardChars`

The modules–those that integrate SoCs–are more popular.

---

Rule `Espressif-devportal.OfxordComma`

Espressif is famous for its SoCs, modules and development boards.

---

Rule `Espressif-devportal.TermsAcronyms`

LP-Core integrates an IMAC CPU.

---

Rules `Espressif-devportal.TermsFixedPattern` and `Espressif-devportal.TermsSingleCorrectSpelling`

Espressif SOCs are famous for its Wi-Fi and bluetooth features. ESP-iDF programming guide is also popular.

---

Rule `Espressif-devportal.UsefulLinkText`

For details, see [here](https://google.com) and [on this page][example].

[example]: https://google.com
