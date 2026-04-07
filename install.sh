#!/bin/bash
set -e

APP_NAME="Boom"
REPO="vladstudio/boom"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -sL "https://github.com/$REPO/releases/latest/download/$APP_NAME.zip" -o "$TMP/$APP_NAME.zip"
unzip -q "$TMP/$APP_NAME.zip" -d "$TMP"

pkill -x "$APP_NAME" 2>/dev/null || true
rm -rf "/Applications/$APP_NAME.app"
mv "$TMP/$APP_NAME.app" /Applications/
open "/Applications/$APP_NAME.app"
echo "==> Installed $APP_NAME"
