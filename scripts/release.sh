#!/bin/bash
set -euo pipefail

version="${1:-1.3.0}"
project_root="$(cd "$(dirname "$0")/.." && pwd)"
build_root="${AVAST_BUILD_ROOT:-$project_root/.build/distribution}"
output_root="${AVAST_OUTPUT_ROOT:-$project_root/dist}"
app="$output_root/AvastShell.app"
archive="$output_root/AvastShell-$version-macOS-universal.zip"

cd "$project_root"
for arch in arm64 x86_64; do
    swift build --configuration release --triple "$arch-apple-macosx15.0" \
        --scratch-path "$build_root/$arch" --disable-local-rpath
    swift build --configuration release --triple "$arch-apple-macosx15.0" \
        --scratch-path "$build_root/$arch" --show-bin-path > "$build_root/$arch/bin-path.txt"
done

mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
arm_bin="$(cat "$build_root/arm64/bin-path.txt")"
intel_bin="$(cat "$build_root/x86_64/bin-path.txt")"
lipo -create "$arm_bin/AvastShellApp" "$intel_bin/AvastShellApp" \
    -output "$app/Contents/MacOS/AvastShellApp"
cp Resources/Info.plist "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $version" "$app/Contents/Info.plist"
cp Resources/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
codesign --force --sign - "$app"
codesign --verify --strict "$app"
ditto -c -k --sequesterRsrc --keepParent "$app" "$archive"
printf 'Release archive: %s\n' "$archive"
