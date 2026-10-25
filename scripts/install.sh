#!/bin/bash
# 从 GitHub Releases 安装 SwitchAmongDisplays。
# curl 下载的文件不会带 com.apple.quarantine，因此不需要手动处理 Gatekeeper。
set -euo pipefail

REPO="Fanloe/SwitchAmongDisplays"
APP="/Applications/SwitchAmongDisplays.app"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ "$(sw_vers -productVersion | cut -d. -f1)" -lt 14 ]]; then
  echo "SwitchAmongDisplays 需要 macOS 14 或更高版本。" >&2
  exit 1
fi

echo "下载最新版本..."
curl -fL --retry 3 -o "$TMP/app.zip" \
  "https://github.com/$REPO/releases/latest/download/SwitchAmongDisplays.zip"

pkill -x SwitchAmongDisplays 2>/dev/null || true
rm -rf "$APP"
unzip -q "$TMP/app.zip" -d /Applications
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

echo "已安装到 $APP"
open "$APP"
