---
title: "Validate and publish content"
date: 2026-05-14
featureAsset: "img/featured/featured-contrib-guide.webp"
tags: ["Contribute"]
showTableOfContents: true
authors:
  - "kirill-chalov"
---

Once you have written your content, validate and publish it:

- Run local checks to catch common issues
- Create a pull request and ask for review
- Once you implement review feedback, the content will be published


## Validate your content

The following local checks are available:

- [Check repo consistency](https://github.com/espressif/developer-portal/tree/main/tools/ci#check-repo-consistency)
- [Check article details](https://github.com/espressif/developer-portal/tree/main/tools/ci#check-article-details)

Once you create a feature branch and commit your content, in the project root, run the checks:

```sh
bash tools/ci/check_repo_consistency.sh
bash tools/ci/check_article_details.sh
```

## Use pre-commit

This feature is work-in-progress.

<details>

This project has a [pre-commit][] hook that can perform the following checks:

- Enforce coding standards and best practices in the project's codebase
- Check links using [lychee][]
  - **Important**: this check requires Docker as a dependency, please make sure it is installed

[pre-commit]: https://pre-commit.com/
[lychee]: https://github.com/lycheeverse/lychee

If you want to use pre-commit, in your project folder, run:

```sh
# Install requirements
pip install -r requirements.txt
# Set up git hook scripts
pre-commit install
# Remove git hook scripts (if not needed)
pre-commit uninstall
```

</details>

## Ask for review

To publish your content on the Espressif Developer Portal, please create a pull request on [espressif / developer-portal][] and invite reviewers from Espressif so that they can make sure your content is in line with Espressif's writing conventions.

[espressif / developer-portal]: https://github.com/espressif/developer-portal "Espressif Developer Portal"


## Next step

> Back to the [Contribution guide](../)
