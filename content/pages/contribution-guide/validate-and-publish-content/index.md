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

## Validate links

For optimal performance, the web links and internal links in the content are validated using different tools.

### Web links

Web links, such as `https://example.com/path/`, are validated by pull request CI using [lychee](https://github.com/lycheeverse/lychee) before the content is published.

You can use `lychee` to test the web links locally, but the installation process might be slightly tedious.

### Internal links

Internal links, such as `/blog/2026/05/esp-who-get-started/` or `../assets/ass-2-1-disable-nvs.webp` are not validated in pull requests. They are validated weekly by a CI cron job. The reasons for that are:

- The job can take up to a few minutes to complete
- Issues with internal links in blog articles are usually obvious during review

To be on the safe side, you can test the internal links locally using [broken-link-checker](https://github.com/stevenvachon/broken-link-checker):

1. Install [broken-link-checker](https://github.com/stevenvachon/broken-link-checker):
    ```sh
    npm install broken-link-checker -g
    ```
2. Run the [local Hugo server](../create-article-scaffold/#preview-the-article)
3. Check internal links and filter only broken ones:<br>
    (the command below assumes the preview is available at `http://localhost:1313/`)
    ```sh
    blc http://localhost:1313/ --recursive --ordered --follow --exclude-external | awk '
      /Getting links from:/ { cluster=""; header=$0; next }
      /BROKEN/ { cluster=cluster $0 "\n"; next }
      /^Finished!/ { if(cluster) { printf "%s\n%s\n", header, cluster } }
    '
    ```
    If `awk` doesn't work for you, run just the `blc` command or use another filtering method.

If any broken links are found, you will see:

```sh
Getting links from: http://localhost:1313/workshops/esp-idf-basic/assignment-2-1/
├─BROKEN─ http://localhost:1313/workshops/esp-idf-basic/assets/ass-2-1-disable-nvs.weebp (HTTP_404)
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
