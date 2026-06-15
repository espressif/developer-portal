# Developer Portal

[![Hugo](https://img.shields.io/static/v1?label=Hugo&message=0.152.2&color=blue&logo=hugo)](https://github.com/gohugoio/hugo/releases/tag/v0.152.2)
[![Theme Blowfish](https://img.shields.io/badge/Hugo--Themes-@Blowfish-blue)](https://themes.gohugo.io/themes/blowfish/)
[![Blowfish](https://img.shields.io/static/v1?label=Blowfish&message=2.92.0&color=blue)](https://github.com/nunocoracao/blowfish/releases/tag/v2.92.0)

[![Minimum Hugo Version](https://img.shields.io/static/v1?label=min-Hugo-version&message=0.141.0&color=blue&logo=hugo)](https://github.com/gohugoio/hugo/releases/tag/v0.141.0)
[![Maximum Hugo Version](https://img.shields.io/static/v1?label=max-Hugo-version&message=0.152.2&color=blue&logo=hugo)](https://github.com/gohugoio/hugo/releases/tag/v0.152.2)


This project stores the files for the [Espressif Developer Portal][] website. GitHub Actions statically generate the website using Hugo and pushes it to a web server for online hosting.

[Espressif Developer Portal]: https://developer.espressif.com/


## Contribute and render locally

If you want to contribute to this project, it would be nice to see the rendered version. The website can be easily rendered on your local machine using the following steps:

1. Clone this repository using `git clone --recursive --shallow-submodules`.
2. Install Hugo following the [instructions](https://gohugo.io/installation/).
3. In the project folder, run `hugo server` and open the provided local web address, usually `http://localhost:1313/`.

See also the [Contribution Guide](https://developer.espressif.com/pages/contribution-guide/).
