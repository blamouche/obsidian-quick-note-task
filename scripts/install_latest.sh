#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-blamouche/obsidian-quick-note-task}"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
APP_DEST_DIR="/Applications"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd hdiutil
require_cmd xattr
require_cmd python3
require_cmd ditto

echo "Fetching latest release from ${REPO}..."
RELEASE_JSON="$(curl -fsSL "$API_URL")"

DMG_URL="$(python3 -c '
import json
import sys

release = json.load(sys.stdin)
for asset in release.get("assets", []):
    url = asset.get("browser_download_url", "")
    if url.endswith(".dmg"):
        print(url)
        break
' <<< "$RELEASE_JSON")"

if [[ -z "$DMG_URL" ]]; then
  echo "No DMG asset found in latest release." >&2
  exit 1
fi

TMP_DIR="$(mktemp -d -t oqnt-install-XXXXXX)"
DMG_PATH="$TMP_DIR/$(basename "$DMG_URL")"
MOUNT_POINT=""

cleanup() {
  if [[ -n "$MOUNT_POINT" ]]; then
    hdiutil detach "$MOUNT_POINT" -quiet || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading DMG..."
curl -fL "$DMG_URL" -o "$DMG_PATH"

echo "Mounting DMG..."
ATTACH_PLIST="$TMP_DIR/attach.plist"
hdiutil attach "$DMG_PATH" -nobrowse -readonly -plist > "$ATTACH_PLIST"

MOUNT_POINT="$(python3 - "$ATTACH_PLIST" <<'PY'
import plistlib
import sys

with open(sys.argv[1], 'rb') as f:
    data = plistlib.load(f)

for entity in data.get('system-entities', []):
    mp = entity.get('mount-point')
    if mp:
        print(mp)
        break
PY
)"

if [[ -z "$MOUNT_POINT" ]]; then
  echo "Failed to detect mounted volume." >&2
  exit 1
fi

APP_SOURCE="$(find "$MOUNT_POINT" -maxdepth 1 -type d -name '*.app' | head -n 1)"
if [[ -z "$APP_SOURCE" ]]; then
  echo "No .app found in mounted DMG." >&2
  exit 1
fi

APP_NAME="$(basename "$APP_SOURCE")"
DEST_PATH="$APP_DEST_DIR/$APP_NAME"

echo "Installing $APP_NAME to $APP_DEST_DIR..."
if [[ -w "$APP_DEST_DIR" ]]; then
  rm -rf "$DEST_PATH"
  ditto "$APP_SOURCE" "$DEST_PATH"
else
  sudo rm -rf "$DEST_PATH"
  sudo ditto "$APP_SOURCE" "$DEST_PATH"
fi

echo "Removing quarantine attribute..."
if [[ -w "$DEST_PATH" ]]; then
  xattr -dr com.apple.quarantine "$DEST_PATH" || true
else
  sudo xattr -dr com.apple.quarantine "$DEST_PATH" || true
fi

echo "Done. App installed at: $DEST_PATH"
