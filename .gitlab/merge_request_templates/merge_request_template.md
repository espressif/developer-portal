
<!--
⚠️ PRE-SUBMISSION REMINDERS
1. Read the project style guidelines (CONTRIBUTING.md).
2. For Work In Progress, please prepend `Draft: ` to your MR title.
3. Ensure you have tested locally with Hugo.
-->

## 📝 Description

<!--
- Summary of the article or changes being introduced.
- Context: Why is this change necessary? (e.g., New tutorial, fixing a typo, updating SDK version).
-->



## Publish date

Expected publish date: `YYYY-MM-DD`

<!--
Please note the expected review time:
  - Announcements:  within 1 week
  - Simple articles:       1-2 weeks
  - Tutorial or workshops: 3-4 weeks
-->

## Review process

- [ ] Initiate **technical review**
    - [ ] This item is N/A
    - Add subject matter experts (your team members, experts in the field)
- [ ] Once tech review mostly done, initiate **editorial review**
    - Add technical editors (`@kirill.chalov`, `@francesco.bez`, and/or `@pedro.minatel`)

## Checks

- [ ] Article folder and file names:
    - Folder path is `content/blog/YYYY/MM/my-new-article` (articles only)
    - Folder and file names have no underscores, spaces, or uppercase letters (~~My new_article~~)
- [ ] New article's YAML frontmatter:
    - Title updated
    - Date matches the format `date: 20YY-MM-DD`
    - Summary updated
    - Authors added (see [Add youself as an author](https://developer.espressif.com/pages/contribution-guide/writing-content/#add-youself-as-an-author))
    - Tags added
- [ ] Updated article's YAML frontmatter:<br>
    - [ ] This item is N/A
    - If article folder is moved or renamed, the field `aliases:` with a new URL slug is added
    - Date of update is added `lastmode: 20YY-MM-DD`
- [ ] Article media files:
    - All images are in .WebP format (see [Use WebP for raster images](https://developer.espressif.com/pages/contribution-guide/writing-content/#use-webp-for-raster-images))
    - Images are compressed within 100-300 KB, with a hard limit of ≤ 500 kB
    - Where possible, Hugo shortcodes are used instead of raw HTML for content types unsupported by markdown (see [Use additional content types](https://developer.espressif.com/pages/contribution-guide/writing-content/#use-additional-content-types))
- [ ] Links in articles
    - Make sure all links are valid
    - No links to Google docs present
    - Use a specific ESP-IDF version in links (avoid `stable`, hard no for `latest`)
- [ ] Git history
    - Commits are clean and squashed to the minimum necessary
    - Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format
    - Your feature branch is rebased on `main`

## 🔗 Related

<!--
- Fixes #ISSUENUMBER
- Related !MRNUMBER
- Links to related documentation
-->



## 🧪 Testing (Hugo)

<!--
Describe how you tested or verified your contribution. For example, you can say:

- [ ] I have run `hugo server` locally and verified there are no build errors.
- [ ] I have checked the rendered output on Desktop and Mobile view.
- [ ] I have verified that internal links and syntax highlighting work correctly.
-->
