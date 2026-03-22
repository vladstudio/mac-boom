#!/bin/bash
set -e
cd "$(dirname "$0")"

swift build -c release

APP=/tmp/Boom.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp app/Boom/Info.plist "$APP/Contents/"
cp .build/release/Boom "$APP/Contents/MacOS/"
cp icons/Boom.icns "$APP/Contents/Resources/"
cp boom-18x2.png "$APP/Contents/Resources/"

pkill -x Boom 2>/dev/null || true
rm -rf /Applications/Boom.app
mv "$APP" /Applications/
touch /Applications/Boom.app
open /Applications/Boom.app
echo "==> Installed Boom.app"
