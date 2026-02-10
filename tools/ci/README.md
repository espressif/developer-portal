# README

This folder contains reusable CI scripts. These scripts are referred to from CI jobs in `.github/workflows` and `.gitlab/ci`.

The idea is to split the CI-independent logic used in CI jobs and keep it in reusable CI scripts. This way a single script can be used in:

- GitHub CI wrapper scripts
- GitLab CI wrapper scripts
- Locally (manual runs, pre-commit hook, etc.)

To run a script locally, go to the repo root and execute:

```bash
bash tools/ci/<script>.sh
```

The following scripts are available:

- [README](#readme)
  - [Check repo consistency](#check-repo-consistency)
  - [Check article details](#check-article-details)

## Check repo consistency

The script `tools/ci/check_repo_consistency.sh` validates the changes that affect the git repo integrity, hugo builds and more. As of now, the following checks are realized:

- Forbidden file types, such as PNG, JPEG, etc.
- In layouts/shortcodes/dynamic-block.html, the setting `localMode` must be false


## Check article details

The script `tools/ci/check_article_details.sh` validates content changes in a feature branch:

- Changed filenames and paths in `content/blog/` and `content/workshops/`:
  - Files and folders must not contain spaces
  - Files and folders must not contain bad characters
- Added articles in `content/blog/`:
  - Folder and date consistency
    - Article must be placed in a `content/blog/YYYY/MM/` folder.
    - The folder year/month must match the article’s `date:` field.
    - Publishing date must not be in the past.
  - Summary
    - A `summary:` field must be present.
    - Must not contain placeholder text.
  - Author
    - The article must include a valid `authors` entry.
- Updated articles in `content/blog/` and `content/workshops/`:
  - Presence and format of `lastmod:`
    - `lastmod:` must exist.
    - It must follow `YYYY-MM-DD`.
    - It must not be earlier than the article’s `date:`.
- Renamed or moved articles in `content/blog/` and `content/workshops/`:
  - Presence of aliases for old URL redirects
