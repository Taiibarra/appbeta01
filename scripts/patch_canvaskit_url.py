import sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

marker = '_flutter.loader.load({\n  config: { canvasKitBaseUrl: "canvaskit/" },'
target = '_flutter.loader.load({'

if marker in content:
    print('already patched, skipping')
elif target in content:
    content = content.replace(target, marker, 1)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print('patched', path)
else:
    print('WARNING: expected _flutter.loader.load({ not found — check flutter_bootstrap.js manually')
    sys.exit(1)
