#!/usr/bin/env bash

set -exu

semanticRelease=$(curl -s https://api.github.com/repos/lwouis/alt-tab-macos/releases/latest | jq -r .tag_name)
version=$(echo "$semanticRelease" | sed 's/^v//')

echo "$version" > $VERSION_FILE
