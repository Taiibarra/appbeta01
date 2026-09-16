#!/usr/bin/env bash
# Builds the Flutter web release and patches flutter_bootstrap.js so
# CanvasKit loads from the app's own bundled files instead of Google's
# gstatic.com CDN. That CDN call gets blocked when the app is hosted
# inside a sandboxed environment (like a published Artifact) that only
# allows scripts from a small list of approved domains, which otherwise
# leaves the app stuck on a blank screen.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build web --release
python3 scripts/patch_canvaskit_url.py build/web/flutter_bootstrap.js

echo ""
echo "Build ready at build/web/. When publishing as an Artifact, include"
echo "canvaskit/canvaskit.{js,wasm} and canvaskit/chromium/canvaskit.{js,wasm}"
echo "alongside the usual files — skip the skwasm* files, they're unused."
