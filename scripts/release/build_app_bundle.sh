#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
APP_BUNDLE_NAME="${APP_BUNDLE_NAME:-ObsidianQuickNoteTask}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-ObsidianQuickNoteTaskApp}"
BUNDLE_ID="${BUNDLE_ID:-com.benoitlamouche.obsidianquicknotetask}"
RELEASE_VERSION="${RELEASE_VERSION:-0.0.0}"

APP_PATH="$DIST_DIR/$APP_BUNDLE_NAME.app"
CONTENTS_PATH="$APP_PATH/Contents"

rm -rf "$APP_PATH"
mkdir -p "$CONTENTS_PATH/MacOS" "$CONTENTS_PATH/Resources"

swift build -c release --product "$EXECUTABLE_NAME"
BIN_PATH="$(swift build -c release --product "$EXECUTABLE_NAME" --show-bin-path)"
cp "$BIN_PATH/$EXECUTABLE_NAME" "$CONTENTS_PATH/MacOS/$EXECUTABLE_NAME"
chmod +x "$CONTENTS_PATH/MacOS/$EXECUTABLE_NAME"

PLIST_PATH="$CONTENTS_PATH/Info.plist"
cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_BUNDLE_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_BUNDLE_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$RELEASE_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$RELEASE_VERSION</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
PLIST

cat >> "$PLIST_PATH" <<'PLIST'
</dict>
</plist>
PLIST

touch "$CONTENTS_PATH/PkgInfo"
echo "APPL????" > "$CONTENTS_PATH/PkgInfo"

echo "App bundle cree: $APP_PATH"
