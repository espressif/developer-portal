# AGENTS.md

This file provides instructions for AI agents working in the [Espressif Developer Portal](https://github.com/espressif/developer-portal) repository. The portal is a Hugo-based static site that publishes technical articles, tutorials, and workshops for Espressif products and the broader ecosystem.

Agents should follow the constraints in this file at all times.


## Environment and Tooling

- **Static site generator**: [Hugo](https://gohugo.io/) extended+deploy edition
  - For the version number, see `README.md` > the Hugo badge
- **Hugo theme**: [Blowfish](https://blowfish.page/)
  - For the version number, see `README.md` > the Blowfish badge
  - Loaded as a git submodule at `themes/blowfish/`
  - The submodule parameters are stored in `.gitmodules`
  - For local deployment, [install Hugo](https://gohugo.io/installation/)
- **Required tools**: `git`, `hugo`
- **Image conversion**: Use `imagemagick` or `cwebp` to convert raster images to WebP


## Site configuration

All Hugo configuration is documented in https://gohugo.io/configuration/introduction/

To override Blowfish files, copy them from `themes/blowfish` to a relevant directory and make respective changes. For example, copy `themes/blowfish/layouts/shortcodes/alert.html` to `layouts/shortcodes/alert.html` and then change it. Don't change files in `themes/blowfish` directly!


## Clone the repo

```sh
# Clone the repo including the Blowfish theme submodule
git clone --recursive --shallow-submodules https://github.com/espressif/developer-portal.git

# If already cloned without submodules, initialize them
git submodule update --init --recursive
```


## Preview the website

Prerequisites:

- Developer portal git project is cloned following `content/pages/contribution-guide/contrib-workflow/index.md`.
- Hugo is installed. Its version must be in the range indicated in the project root's `README.md` between `Minimum Hugo Version` and `Maximum Hugo Version`.

Once prerequisites are satisfied, preview the website following the guidelines in `content/pages/contribution-guide/create-article-scaffold/index.md#preview-the-article`


## Article lifecycle

### Create an article

Follow guidelines in `content/pages/contribution-guide/create-article-scaffold/index.md#create-an-article`:

- Create a new blog article
- When adding files, follow the recommended article folder structure and naming conventions

### Fill out the blog article front matter

Follow guidelines in `content/pages/contribution-guide/create-article-scaffold/index.md#fill-out-the-blog-article-front-matter`:

- To fill out the author field, create an author according to the _Add an author_ section
- For remaining fields, follow the guidelines and comments in the front matter
- Reference existing articles for examples, such as `content/blog/2026/03/introducing-spiffs-component/index.md`

### Add an author

Follow guidelines in `content/pages/contribution-guide/create-article-scaffold/index.md#add-youself-as-an-author`:

- Create an author using the script `tools/create_author.py`
- Ask the human to fill out all missing details

### Create publication essentials

Humans should ideally write these before drafting content, but you can revisit after writing:

**Article summary**: See `content/pages/contribution-guide/write-and-format-content/index.md#write-an-article-summary`

**Tags**: See `content/pages/contribution-guide/write-and-format-content/index.md#tag-the-content`

**Featured image**: Guidelines at `content/pages/contribution-guide/write-and-format-content/index.md#prepare-a-featured-image`

### Follow the guidelines for structuring content

Find guidelines and best practices at `content/pages/contribution-guide/write-and-format-content/index.md#follow-the-guidelines-for-structuring-content`

### Review supported media and content types

We use markdown with Hugo shortcodes that extend functionality. Hugo, the Hugo theme, and our customizations in `layouts/shortcodes` provide various shortcodes for rich content.

Review available content types, requirements, and usage at `content/pages/contribution-guide/write-and-format-content/index.md#review-supported-media-and-content-types`

### Validate your content

The validation scripts compare the default branch with the feature branch to identify added commits, then validate them against internal logic.

Ensure a feature branch exists with commits added, then run validation scripts following `content/pages/contribution-guide/validate-and-publish-content/index.md#validate-your-content`

**Your role in validation**:

- Fix simple or straightforward issues yourself
- Involve a human for issues requiring decisions or informed choices

### Create a PR or MR

Depending on the chosen workflow (`content/pages/contribution-guide/contrib-workflow/index.md`), create a pull request or merge request if you have permissions. Once reviewed and approved, maintainers will publish it.
