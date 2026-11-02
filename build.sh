#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
APP="build/AeroSpace Config.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/ModuleCache
swiftc -module-cache-path "$PWD/build/ModuleCache" AeroSpaceStudio.swift -framework Cocoa -framework WebKit -o "$APP/Contents/MacOS/AeroSpaceStudio"
cp index.html "$APP/Contents/Resources/index.html"
cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>AeroSpaceStudio</string>
<key>CFBundleIdentifier</key><string>app.aerospace.config</string>
<key>CFBundleName</key><string>AeroSpace Config</string>
<key>CFBundleDisplayName</key><string>AeroSpace Config</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>CFBundleShortVersionString</key><string>1.1</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSPrincipalClass</key><string>NSApplication</string>
<key>NSHighResolutionCapable</key><true/>
<key>CFBundleIconFile</key><string>AppIcon</string>
</dict></plist>
PLIST
xattr -cr "$APP"
codesign --force --deep --sign - "$APP"
echo "Built $APP"
