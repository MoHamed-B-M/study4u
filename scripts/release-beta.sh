#!/usr/bin/env bash
set -euo pipefail

# ─── Study4u Beta Release v2.0.0-beta.1 ─────────────────────────────────────
# Usage:  chmod +x scripts/release-beta.sh && ./scripts/release-beta.sh
# Prereq: gh CLI authenticated, Flutter SDK on PATH, jq installed
# ──────────────────────────────────────────────────────────────────────────────

RELEASE_TAG="v2.0.0-beta.1"
RELEASE_TITLE="🚀 Study4u Beta: The Comic-Print Overhaul & Performance Update"
REPO="MoHamed-B-M/study4u"
FEEDBACK_URL="https://github.com/MoHamed-B-M/study4u/issues/new"

echo "═══ Study4u Beta Release — $RELEASE_TAG ═══"

# ── 1. Clean previous builds ──
echo ">>> Cleaning previous build artifacts..."
flutter clean
rm -rf build/app/outputs/flutter-apk/release

# ── 2. Build split APKs ──
echo ">>> Building release APKs (split-per-abi)..."
flutter build apk --release --split-per-abi

APK_DIR="build/app/outputs/flutter-apk/release"
echo ">>> Verifying APK assets..."
ls -lh "$APK_DIR"/*.apk

# ── 3. Build release notes file ──
echo ">>> Preparing release notes..."
NOTES_FILE=$(mktemp)

# Extract v2.0.0 section from CHANGELOG.md
awk '/^## \[2\.0\.0\]/,/^## \[/{ if (!/^## \[[12]\./) print }' CHANGELOG.md > "$NOTES_FILE"

# Append feedback CTA
cat >> "$NOTES_FILE" <<EOF

---

## 💬 We Need Your Feedback!

This is a **Beta release** — we want to hear from you!

- 🐛 **Found a bug?**  → [Open an issue]($FEEDBACK_URL)
- 💡 **Have a suggestion?**  → [Open a feature request]($FEEDBACK_URL)
- 🎨 **UI/UX feedback?**  → [Log layout tickets]($FEEDBACK_URL)

Your input shapes the next stable release. Thank you for testing! 🙏
EOF

echo ">>> Release notes preview:"
head -20 "$NOTES_FILE"

# ── 4. Create GitHub pre-release ──
echo ">>> Creating GitHub pre-release $RELEASE_TAG..."
gh release create "$RELEASE_TAG" \
  --repo "$REPO" \
  --prerelease \
  --title "$RELEASE_TITLE" \
  --notes-file "$NOTES_FILE" \
  "$APK_DIR"/app-arm64-v8a-release.apk \
  "$APK_DIR"/app-armeabi-v7a-release.apk \
  "$APK_DIR"/app-x86_64-release.apk

# ── 5. Cleanup ──
rm -f "$NOTES_FILE"

echo ""
echo "═══ Done! ═══"
echo "Release page: https://github.com/$REPO/releases/tag/$RELEASE_TAG"
