# Theme override maintenance guide

This site uses the [Blowfish](https://blowfish.page/) theme as a Git submodule
(`themes/blowfish`). Files in `layouts/` override matching paths under
`themes/blowfish/layouts/`. Hugo always prefers site layouts over theme layouts.

When bumping Blowfish, treat each override as a three-way merge:

1. **Old theme version** (the submodule commit you last synced against)
2. **New theme version** (the submodule commit you are moving to)
3. **Site override** (intentional portal behavior)

Reconcile upstream theme changes first, then re-apply site-specific deltas.

---

## Why each override exists

### Layout shell and global partials

| File | Why it exists |
|------|----------------|
| `_default/baseof.html` | Keeps site-specific page shell behavior: extra main-content bottom padding for the Kapa widget, disables the Buy Me a Coffee widget, and adopts upstream Blowfish body/scrollbar updates. |
| `partials/head.html` | Adds portal asset loading (`features/*` partials). Extends Blowfish's social-image fallback: resolve `featureimage`, then `featureAsset`, then page-bundle images (same order as `hero/basic.html`), call Hugo's Open Graph/Twitter internals, then emit `og:image` / `twitter:image` when a resolved image or `defaultSocialImage` is available. Stays aligned with upstream head changes (SEO metadata order, Fuse search bundle, email/print JS, hreflang links). |
| `partials/header/basic.html` | Uses Blowfish's component-based header (desktop/mobile menu components) while keeping portal logo scaling, site title emojify, subnavigation emojify, and `assets/css/styles.css`. |
| `partials/footer.html` | Keeps Espressif copyright text/emojify and removes deprecated upstream scripts no longer used by the portal. |
| `partials/home/custom.html` | Portal homepage customization (not in Blowfish). |

### Article and list rendering

| File | Why it exists |
|------|----------------|
| `_default/list.html` | Applies upstream list/TOC layout changes while keeping `\| emojify` on list page content. |
| `_default/single.html` | Merges upstream single-page changes (TOC, reply-by-email obfuscation, `hugo.Data.authors`) with portal article features: summary block, emojify, author disclaimer, Giscus, Mermaid init. |
| `partials/hero/basic.html` | Supports `featureAsset` images from site assets in hero backgrounds, on top of upstream hero markup. |
| `partials/article-link/card.html` | Supports `featureAsset` for card thumbnails and restores portal card shadows (`shadow-2xl`) on upstream card markup. |
| `partials/article-link/card-related.html` | Same as card view, for related-articles cards. |
| `partials/article-link/_shortcode.html` | Same as card view, for the `article` shortcode card rendering. |
| `partials/author-extra.html` | Merges upstream author image/email-link improvements with Espressif/partner/community byline branding. |
| `partials/author-disclaimer.html` | Shows third-party author disclaimer when no Espressif author is present (portal-only). |
| `authors/terms.html` | Groups author taxonomy terms into Espressif / partner / community sections (portal-only). |

### Shortcodes

| File | Why it exists |
|------|----------------|
| `shortcodes/article.html` | Keeps PR preview subpath link resolution while adopting upstream multilingual lookup (`site.LanguagePrefix`, `hugo.Sites`). |
| `shortcodes/github.html` | Keeps portal GitHub card styling on upstream shortcode logic (`hugo.Data.repoColors`, fetch script). |
| `shortcodes/recent-tagged.html` | Portal-only shortcode. |
| `shortcodes/external-page.html` | Portal-only shortcode. |
| `shortcodes/dynamic-block.html` | Portal-only shortcode. |
| `shortcodes/bilibili-note.html` | Portal-only shortcode. |
| `shortcodes/asciinema.html` | Portal-only shortcode. |

### Feature partials (portal-only)

| File | Why it exists |
|------|----------------|
| `partials/features/giscus-auto.html` | Auto-select Giscus theme. |
| `partials/features/giscus_dark.html` | Dark Giscus theme partial. |
| `partials/features/giscus_light.html` | Light Giscus theme partial. |
| `partials/features/mermaid-init.html` | Mermaid initialization for articles. |
| `partials/features/kapa-widget.html` | Kapa AI widget injection. |
| `partials/features/vendor_custom.html` | Loads portal vendor assets (e.g. Asciinema). |
| `partials/features/dynamic_md_block.html` | Dynamic markdown block support. |

### Markup render hooks

| File | Why it exists |
|------|----------------|
| `_default/_markup/render-codeblock-mermaid.html` | Portal Mermaid code block rendering hook. |

---

## How changes are split into commits (and why)

Commits are grouped by **intent**, not just by directory. That makes the next
Blowfish bump easier to replay.

| Commit group | Typical files | Why separate |
|--------------|---------------|--------------|
| Submodule bump | `themes/blowfish` pointer | Isolates "theme moved" from override reconciliation. |
| Override sync with Blowfish | `baseof`, `head`, `list`, `single`, `header/basic`, `footer`, `hero/basic`, `author-extra`, `article-link/*`, `shortcodes/article.html`, `shortcodes/github.html` | These are mostly upstream layout changes plus small portal deltas. Diff old→new theme for each path, then re-apply portal edits. |
| Hugo modernization | `author-disclaimer.html`, `authors/terms.html`, removal of `js/page.js` references | Deprecation/cleanup work unrelated to Blowfish UI redesign. |
| Portal styling choices | `shadow-2xl` on article cards | Intentional visual policy; easy to revert without touching merge work. |
| Documentation | `layouts/theme-overrides.md` | Checklist for the next bump; documents override intent. |

### Files usually unchanged during a bump

Portal-only overrides (`partials/features/*`, portal shortcodes, `authors/terms.html`
logic, `author-disclaimer.html`) rarely need changes unless Hugo API deprecations
affect them.

### Content conventions

- **Tabs:** use upstream Blowfish syntax with `tabs` / `tab` shortcodes and `group` / `label` parameters.
- **Video:** use extensioned bundle paths in content (e.g. `src="video/foo.mp4"`) with the upstream Blowfish `video` shortcode.

---

## Recommended bump workflow

1. Update `themes/blowfish` submodule and commit the pointer change alone.
2. For each file listed under **Override sync with Blowfish**, run:
   `git diff OLD_THEME_COMMIT..NEW_THEME_COMMIT -- layouts/<path>`
3. Merge upstream changes into the site override, preserving rows in the tables above.
4. Build with the new Hugo version and fix deprecations/shims as needed.
5. Update this document if override intent changes.

---

## Last synced Blowfish commit

Update this after each successful bump.

| Field | Value |
|-------|-------|
| Last synced theme commit | `51b5cd932055e51519a689699aba716fab47409b` |
| Previous sync baseline | `81f0e887100f4ddc9856c6d662883b62ab7b1043` (Blowfish 2.92.0) |
| Sync date | 2026-06-26 |

---

## Example prompt to start the next bump

Copy the prompt below into your agent chat. Replace the placeholders, then send.

```text
I need to bump the Blowfish theme submodule and reconcile our layout overrides.

Context:
- Repo: developer-portal
- Theme submodule: themes/blowfish
- Last synced Blowfish commit: <OLD_COMMIT>   # see "Last synced Blowfish commit" above
- New Blowfish commit/tag: <NEW_COMMIT_OR_TAG>
- Hugo version (if changed): <HUGO_VERSION>

Our site overrides live in ./layouts/ and are documented in layouts/theme-overrides.md.
Read that file first — it explains why each override exists and how commits should be grouped.

Task:
1. Update themes/blowfish to <NEW_COMMIT_OR_TAG> and commit the submodule pointer alone.
2. For every file in ./layouts/ that also exists in themes/blowfish/layouts/, compare:
   - theme at <OLD_COMMIT>
   - theme at <NEW_COMMIT_OR_TAG>
   - our override in ./layouts/
   Merge upstream theme changes into our overrides while preserving site-specific behavior
   documented in theme-overrides.md.
3. Run `hugo --gc --minify` and fix build errors.
4. Split the work into commits by intent (see "How changes are split into commits"):
   - submodule bump
   - override sync with Blowfish
   - Hugo modernization / deprecations
   - portal styling choices (if any)
   - update layouts/theme-overrides.md (including "Last synced Blowfish commit")
   - compatibility shims last, if any remain
5. Do not commit unrelated files.

If anything is ambiguous, ask before making large structural changes (especially header/menu overrides).
```

### Example filled in (2026-06 bump)

```text
I need to bump the Blowfish theme submodule and reconcile our layout overrides.

Context:
- Repo: developer-portal
- Theme submodule: themes/blowfish
- Last synced Blowfish commit: 81f0e887100f4ddc9856c6d662883b62ab7b1043
- New Blowfish commit/tag: 51b5cd932055e51519a689699aba716fab47409b
- Hugo version (if changed): 0.161.1

Our site overrides live in ./layouts/ and are documented in layouts/theme-overrides.md.
Read that file first — it explains why each override exists and how commits should be grouped.

Task:
1. Update themes/blowfish to 51b5cd932055e51519a689699aba716fab47409b and commit the submodule pointer alone.
2. For every file in ./layouts/ that also exists in themes/blowfish/layouts/, compare:
   - theme at 81f0e887100f4ddc9856c6d662883b62ab7b1043
   - theme at 51b5cd932055e51519a689699aba716fab47409b
   - our override in ./layouts/
   Merge upstream theme changes into our overrides while preserving site-specific behavior
   documented in theme-overrides.md.
3. Run `hugo --gc --minify` and fix build errors.
4. Split the work into commits by intent (see "How changes are split into commits"):
   - submodule bump
   - override sync with Blowfish
   - Hugo modernization / deprecations
   - portal styling choices (if any)
   - update layouts/theme-overrides.md (including "Last synced Blowfish commit")
   - compatibility shims last, if any remain
5. Do not commit unrelated files.

If anything is ambiguous, ask before making large structural changes (especially header/menu overrides).
```
