# SwitchAmongDisplays

[![macOS](https://img.shields.io/badge/macOS-14.0%2B-orange?logo=apple)](https://developer.apple.com/macos/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0%2B-F05138?logo=swift)](https://developer.apple.com/xcode/swiftui/)

A simple utility app that lets you quickly switch between displays using a keyboard shortcut. Perfect for multi-monitor setups!

![App Screenshot](docs/screenshot.png)

## Features

- ⚡ Instantly switch between displays with a keyboard shortcut
- 🔄 Cycles through all connected displays in order
- 🌐 Lightweight background utility (less than 5MB memory usage)
- 🛠️ Zero configuration - just run and use

## Installation

### 一键安装（推荐）

```bash
curl -fsSL https://github.com/Fanloe/SwitchAmongDisplays/releases/latest/download/install.sh | bash
```

### 手动安装

1. 从 [Releases](https://github.com/Fanloe/SwitchAmongDisplays/releases/latest) 下载 `SwitchAmongDisplays.zip`
2. 解压后把 `SwitchAmongDisplays.app` 拖进 `/Applications`
3. 首次打开前，在终端执行（否则 macOS 会提示“已损坏，无法打开”）：
   ```bash
   xattr -dr com.apple.quarantine /Applications/SwitchAmongDisplays.app
   ```
   或者先双击打开一次，被拦截后到 **系统设置 → 隐私与安全性** 点击 **仍要打开**。

   > 应用没有 Apple 开发者签名和公证，所以下载后需要手动放行一次。macOS 15 起右键 → 打开的方式已失效。

4. 启动后系统会弹窗请求辅助功能权限，点“打开系统设置”并勾选本应用即可。

### 从源码构建

工程已配置为 ad-hoc 签名（Sign to Run Locally），**不需要 Apple 开发者账号**：

1. Clone 本仓库，用 Xcode 打开 `SwitchAmongDisplays.xcodeproj`
2. 选择 `SwitchAmongDisplays` scheme，⌘ + R 运行

或使用命令行：

```bash
xcodebuild -scheme SwitchAmongDisplays -configuration Release -derivedDataPath build build
open build/Build/Products/Release/SwitchAmongDisplays.app
```

### 发布（维护者）

1. 首次发布：运行 `./scripts/make-signing-cert.sh`，把 `signing/key.pem` 离线备份；将 `signing/cert.p12.base64` 和 `signing/p12-password.txt` 分别设置为仓库 Secrets `SIGNING_CERT_P12`、`SIGNING_CERT_PASSWORD`（`signing/cert.pem` 是公开证书，随仓库提交）
2. 推送 `v*` tag，CI 会构建 universal binary、用固定证书重签、验证并发布 Release

证书私钥丢失或轮换会导致所有用户下次更新时需要重新授权辅助功能。

## Setup Instructions (Critical)

The app asks for Accessibility permission on first launch. If you dismiss the prompt, grant it manually:

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Click the **+** button at the bottom of the list
3. Navigate to `/Applications` and select `SwitchAmongDisplays.app`
4. Check the box next to the app in the list

![Accessibility Permissions Setup](docs/permissions-setup.png)

> ⚠️ **更新后如果快捷键失效**：到辅助功能列表里删除旧条目，再重新添加即可。从使用固定自签名证书的版本开始，之后正常更新不再需要重新授权。

### 签名说明

发布包使用固定证书 `SwitchAmongDisplays Self-Signed` 签名（不是 Apple 开发者签名，也未经公证），因此仍需要手动放行 Gatekeeper 一次。但由于证书固定，macOS 的辅助功能授权绑定的是证书而不是每次构建的哈希，后续版本更新可以沿用同一份授权。

## Usage

- Press **⌘ + ⇧ + D** (Command + Shift + D) to switch to the next display
- The app runs as a menu bar utility (no Dock icon)
- To quit: click the menu bar icon → **退出**

## Troubleshooting

| Issue | Solution |
|-------|----------|
| “已损坏，无法打开” | 执行 `xattr -dr com.apple.quarantine /Applications/SwitchAmongDisplays.app` |
| Shortcut not working | Verify Accessibility permissions are granted |
| Only cycles through some displays | Make sure all displays are detected in System Settings → Displays |
| App crashes on launch | Check Console.app for error logs |
| Cursor jumps but doesn't stay | May require restarting the app after display changes |

## Building for Development

```bash
# Clean build
xcodebuild clean

# Build (ad-hoc signed, no developer account needed)
xcodebuild -scheme SwitchAmongDisplays -configuration Debug -derivedDataPath build

# Run from command line
open build/Build/Products/Debug/SwitchAmongDisplays.app
```

## Contributing

Pull requests are welcome! Please open an issue first to discuss proposed changes.

## License

[MIT](LICENSE)