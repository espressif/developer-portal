---
title: "{{ replace .Name "-" " " | title }}"
date: "{{ now.Format "2006-01-02" }}"
# If default Espressif author is needed, uncomment this
# showAuthor: true
# Add a summary
summary: "Replace it with a brief summary that captures the essence of (1) what the article is about and (2) how the reader will benefit from reading it. For examples, check other article summaries."
# Create your author entry (for details, see https://developer.espressif.com/pages/contribution-guide/writing-content/#add-youself-as-an-author)
#  - Create your page at `content/authors/<author-name>/_index.md`
#  - Add your personal data at `data/authors/<author-name>.json`
#  - Add author name(s) below
authors:
  - "author-name" # same as in the file paths above
# Add tags
tags: ["Tag1", "Tag2"]
---
