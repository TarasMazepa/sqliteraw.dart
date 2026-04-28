import sys
with open('sqliteraw/pubspec.yaml', 'r') as f:
    content = f.read()

content = content.replace("assetId: 'sqliteraw.dart'", "asset-id: 'sqliteraw.dart'")

with open('sqliteraw/pubspec.yaml', 'w') as f:
    f.write(content)
