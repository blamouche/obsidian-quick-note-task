#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <app_path> [output_dmg]"
  exit 1
fi

APP_PATH="$1"
OUTPUT_DMG="${2:-}"

if [[ -z "$OUTPUT_DMG" ]]; then
  BASE_NAME="$(basename "$APP_PATH" .app)"
  OUTPUT_DMG="$(dirname "$APP_PATH")/${BASE_NAME}.dmg"
fi

VOL_NAME="$(basename "$APP_PATH" .app)"
rm -f "$OUTPUT_DMG"

hdiutil create -volname "$VOL_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$OUTPUT_DMG"

echo "DMG cree: $OUTPUT_DMG"
