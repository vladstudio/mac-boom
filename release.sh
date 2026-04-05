#!/bin/bash
set -e
cd "$(dirname "$0")"
source ../mac-scripts/release-kit.sh
release_app "Boom" --info app/Boom/Info.plist
