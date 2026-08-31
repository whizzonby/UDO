#!/usr/bin/env bash
#
# One-shot iOS release build for Udo. Run on the Mac from apps/mobile/:
#
#   ./scripts/ios_release.sh
#
# Produces build/ios/ipa/*.ipa ready to upload via Xcode Organizer / Transporter.
# Prereqs (see docs/APP_STORE_SUBMISSION.md sections 5b-5d):
#   - flutter + cocoapods installed, `flutter doctor` green for Xcode + CocoaPods
#   - Signing team selected once in Xcode (Runner target -> Signing & Capabilities)
#   - Google iOS client id filled into ios/Runner/Info.plist (section 3c)
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Flutter version"
flutter --version

echo "==> flutter pub get"
flutter pub get

echo "==> Codegen (retrofit / riverpod / json_serializable)"
dart run build_runner build --delete-conflicting-outputs

echo "==> CocoaPods"
( cd ios && pod install )

echo "==> Guarding against unfilled placeholders"
if grep -q "REPLACE_WITH_IOS_CLIENT_ID" ios/Runner/Info.plist; then
  echo "!! ios/Runner/Info.plist still has REPLACE_WITH_IOS_CLIENT_ID."
  echo "!! Fill in the Google iOS client id first (docs section 3c), or Google"
  echo "!! sign-in will fail App Review. Continuing anyway in 5s..."
  sleep 5
fi

echo "==> flutter clean + build ipa"
flutter clean
flutter build ipa --release

echo
echo "Done. Archive + ipa:"
echo "  build/ios/archive/Runner.xcarchive"
echo "  build/ios/ipa/"
echo
echo "Next: Xcode -> Window -> Organizer -> Archives -> Distribute App"
echo "      (or drag the .ipa into the Transporter app)."
