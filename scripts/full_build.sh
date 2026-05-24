
#!/usr/bin/env bash

# Determine next ver
semanticRelease=$(curl -s https://api.github.com/repos/lwouis/alt-tab-macos/releases/latest | jq -r .tag_name)
version=$(echo "$semanticRelease" | sed 's/^v//')



#replace
cat > config/local.xcconfig <<EOF
CURRENT_PROJECT_VERSION = $version
EOF


#build 
set -ex

set -o pipefail && xcodebuild -project alt-tab-macos.xcodeproj -scheme Release -derivedDataPath DerivedData CURRENT_PROJECT_VERSION=$version | scripts/xcbeautify
file "DerivedData/Build/Products/Release/AltTab.app/Contents/MacOS/AltTab"

mkdir builds
cp -r DerivedData/Build/Products/Release/AltTab.app builds/

