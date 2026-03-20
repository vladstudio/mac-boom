#!/bin/bash
set -e
cd "$(dirname "$0")"

swift build -c release

APP=app/Boom.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/Boom "$APP/Contents/MacOS/"
cp app/Boom/Info.plist "$APP/Contents/"
touch "$APP"

echo "==> Built Boom.app"

killall Boom 2>/dev/null || true
rm -rf /Applications/Boom.app
mv "$APP" /Applications/
open /Applications/Boom.app
