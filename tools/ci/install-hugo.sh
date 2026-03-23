#!/usr/bin/env bash
set -euo pipefail

# When updating Hugo version, update Hugo version range in project README
HUGO_VERSION="0.152.2"
HUGO_DEB="${RUNNER_TEMP:-/tmp}/hugo.deb"

wget --progress=dot:giga -O "$HUGO_DEB" "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_withdeploy_${HUGO_VERSION}_linux-amd64.deb" \
  && sudo dpkg -i "$HUGO_DEB"
