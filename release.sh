#!/bin/bash
set -e
cd "$(dirname "$0")"

CURRENT=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
VERSION=${1:-${CURRENT%.*}.$((${CURRENT##*.} + 1))}
echo "==> $CURRENT -> $VERSION"

plutil -replace CFBundleShortVersionString -string "$VERSION" app/Boom/Info.plist
plutil -replace CFBundleVersion -string "$VERSION" app/Boom/Info.plist

swift build -c release

APP=/tmp/Boom.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp app/Boom/Info.plist "$APP/Contents/"
cp .build/release/Boom "$APP/Contents/MacOS/"
cp icons/Boom.icns "$APP/Contents/Resources/"
codesign --force --deep --sign - "$APP"

git add app/Boom/Info.plist
git commit -m "v$VERSION"
git tag "v$VERSION"
git push --tags

ditto -c -k --sequesterRsrc --keepParent "$APP" /tmp/Boom.zip
gh release create "v$VERSION" /tmp/Boom.zip --title "v$VERSION" --notes ""
echo "==> Released v$VERSION"
