#!/usr/bin/env bash
# Rebuilds the Flutter web app and refreshes docs/, which is what GitHub
# Pages serves. Run this after any code change you want live, then:
#   git add docs && git commit -m "Update web build" && git push
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build web --release --pwa-strategy none
python3 scripts/patch_canvaskit_url.py build/web/flutter_bootstrap.js

rm -rf docs
mkdir -p docs
cp -R build/web/. docs/
rm -f docs/.last_build_id docs/flutter_service_worker.js
rm -f docs/canvaskit/skwasm*.js docs/canvaskit/skwasm*.wasm \
      docs/canvaskit/skwasm*.symbols docs/canvaskit/*.symbols \
      docs/canvaskit/chromium/*.symbols

echo ""
echo "docs/ updated ($(du -sh docs | cut -f1)). Next steps:"
echo "  git add docs"
echo "  git commit -m \"Update web build\""
echo "  git push"
