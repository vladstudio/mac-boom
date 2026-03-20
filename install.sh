#!/bin/bash
set -e

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

URL=$(curl -sL https://api.github.com/repos/nicedoc/mac-boom/releases/latest \
  | grep browser_download_url | head -1 | cut -d'"' -f4)
curl -sL "$URL" -o "$TMP/Boom.zip"
unzip -q "$TMP/Boom.zip" -d "$TMP"

pkill -x Boom 2>/dev/null || true
rm -rf /Applications/Boom.app
mv "$TMP/Boom.app" /Applications/
xattr -dr com.apple.quarantine /Applications/Boom.app 2>/dev/null || true
open /Applications/Boom.app
echo "==> Installed Boom"
