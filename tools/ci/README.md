# README

This folder contains CI scripts. These scripts are referred to from CI jobs in `.github/workflows` and `.gitlab/ci`.

The idea is to split the CI-independent logic used in CI jobs and keep it in the scripts. This way a single script can be used in:

- GitHub CI wrapper scripts
- GitLab CI wrapper scripts
- Locally (manual runs, pre-commit hook, etc.)

To run a script locally, go to the repo root and execute:

```bash
bash tools/ci/check_article_details.sh
```

## Check article details

This script validates content changes in a feature branch:

Added articles in `content/blog/**/index.md`:

- Folder and date consistency
  - Article must be placed in a `content/blog/YYYY/MM/` folder.
  - The folder year/month must match the article’s `date:` field.
  - Publishing date must not be in the past.
- Summary
  - A `summary:` field must be present.
  - Must not contain placeholder text.
- Author
  - The article must include a valid `authors` entry.

Updated articles in `content/blog/**/index.md` and `content/workshops/**/index.md`:

- Presence and format of `lastmod:`
  - `lastmod:` must exist.
  - It must follow `YYYY-MM-DD`.
  - It must not be earlier than the article’s `date:`.
