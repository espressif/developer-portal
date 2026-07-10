#!/usr/bin/env python3
"""Create Hugo author files (content + data) with sensible defaults.

See: https://developer.espressif.com/pages/contribution-guide/writing-content/#add-youself-as-an-author
"""

from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

CONTRIBUTION_GUIDE_ADD_AUTHOR = (
    "https://developer.espressif.com/pages/contribution-guide/writing-content/"
    "#add-youself-as-an-author"
)


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def slugify(display_name: str) -> str:
    normalized = unicodedata.normalize("NFKD", display_name.strip())
    ascii_name = "".join(c for c in normalized if not unicodedata.combining(c))
    lowered = ascii_name.lower()
    slug = re.sub(r"[^a-z0-9]+", "-", lowered)
    slug = slug.strip("-")
    slug = re.sub(r"-{2,}", "-", slug)
    return slug


def prompt_display_name() -> str:
    print("Enter the author name...")
    print("Example: John Doe")
    print()
    while True:
        raw = input("Author name: ").strip()
        if raw:
            return raw
        print("Author name is required. Example: John Doe\n")


def author_paths(root: Path, slug: str) -> tuple[Path, Path]:
    index_md = root / "content" / "authors" / slug / "_index.md"
    data_json = root / "data" / "authors" / f"{slug}.json"
    return index_md, data_json


def write_author(root: Path, display_name: str, slug: str) -> tuple[Path, Path]:
    index_md, data_json = author_paths(root, slug)

    if index_md.exists() or data_json.exists():
        print(
            "Error: an author with this slug already exists:\n"
            f"  {index_md}\n"
            f"  {data_json}\n"
            "Choose a different display name or remove the existing author first.",
            file=sys.stderr,
        )
        sys.exit(1)

    index_md.parent.mkdir(parents=True, exist_ok=True)

    front_matter_title = json.dumps(display_name, ensure_ascii=False)
    index_body = f"""---
title: {front_matter_title}
---

<!-- (optional) Add a few words about yourself  -->
"""
    index_md.write_text(index_body, encoding="utf-8")

    author_data = {
        "name": display_name,
        "type": "espressif",
        "image": "img/authors/espressif.webp",
        "bio": "",
        "social": [],
    }
    json_text = json.dumps(author_data, indent=4, ensure_ascii=False) + "\n"
    data_json.write_text(json_text, encoding="utf-8")

    return index_md, data_json


def main() -> None:
    root = repo_root()
    display_name = prompt_display_name()
    slug = slugify(display_name)

    if not slug:
        print(
            "Error: could not derive a valid author slug from that name.\n"
            "Use letters and numbers (e.g. John Doe).",
            file=sys.stderr,
        )
        sys.exit(1)

    print()
    print(f"Author slug (for paths and YAML): {slug}")
    print()

    index_md, data_json = write_author(root, display_name, slug)

    rel_index = index_md.relative_to(root)
    rel_json = data_json.relative_to(root)

    print("Created:")
    print()
    print(f"- Personal author page at `{rel_index}`")
    print("  - (optional) add more details about yourself")
    print(f"- Personal data at `{rel_json}`")
    print("  - (recommended) add your profile image")
    print("  - (recommended) fill out author type, bio, and social links")
    print()
    print("Full instructions and field descriptions:")
    print(f"  {CONTRIBUTION_GUIDE_ADD_AUTHOR}")
    print()
    print("Add this to your article front matter when ready:")
    print("  authors:")
    print(f'    - "{slug}"')


if __name__ == "__main__":
    main()
