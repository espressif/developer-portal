#!/usr/bin/env bash
set -euo pipefail

# When updating Hugo version, update Hugo version range in project README
HUGO_VERSION="0.169.0"
HUGO_DEB="${RUNNER_TEMP:-/tmp}/hugo.deb"

wget --progress=dot:giga -O "$HUGO_DEB" \
  "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_withdeploy_${HUGO_VERSION}_linux-amd64.deb"

# GitHub-hosted runners are unprivileged and have sudo. The GitLab Debian
# image runs as root and does not install sudo.
if [ "$(id -u)" -eq 0 ]; then
  dpkg -i "$HUGO_DEB"
else
  sudo dpkg -i "$HUGO_DEB"
fi
