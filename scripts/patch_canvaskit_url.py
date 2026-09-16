import sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

config_snippet = 'config: { canvasKitBaseUrl: "canvaskit/" }'

if config_snippet in content:
    print('already patched, skipping')
elif '_flutter.loader.load({' in content:
    content = content.replace(
        '_flutter.loader.load({',
        f'_flutter.loader.load({{\n  {config_snippet},',
        1,
    )
elif '_flutter.loader.load();' in content:
    content = content.replace(
        '_flutter.loader.load();',
        f'_flutter.loader.load({{ {config_snippet} }});',
        1,
    )
else:
    print('WARNING: no recognized _flutter.loader.load(...) call found — check flutter_bootstrap.js manually')
    sys.exit(1)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('patched', path)
