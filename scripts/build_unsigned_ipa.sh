#!/usr/bin/env bash
# Build an unsigned IPA on macOS (CI or local Xcode). Sideloadly will resign it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DERIVED="${ROOT}/build/DerivedData"
APP_PATH="${DERIVED}/Build/Products/Release-iphoneos/ClosetScan.app"
IPA_DIR="${ROOT}/build/ipa"
PAYLOAD="${IPA_DIR}/Payload"
IPA_OUT="${ROOT}/build/ClosetScan.ipa"

rm -rf "${ROOT}/build"
mkdir -p "$DERIVED" "$PAYLOAD"

xcodebuild \
  -project ClosetScan.xcodeproj \
  -scheme ClosetScan \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=NO \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: ClosetScan.app not found at $APP_PATH" >&2
  find "$DERIVED" -name "ClosetScan.app" -type d >&2 || true
  exit 1
fi

cp -R "$APP_PATH" "$PAYLOAD/"
(
  cd "$IPA_DIR"
  zip -r "$IPA_OUT" Payload
)

echo "IPA ready: $IPA_OUT"
ls -lh "$IPA_OUT"
