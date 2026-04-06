#!/bin/bash
set -e
cd "$(dirname "$0")"
source ../mac-scripts/build-kit.sh
build_app "Boom" \
  --info app/Boom/Info.plist \
  --resources "boom-18x2.png"
