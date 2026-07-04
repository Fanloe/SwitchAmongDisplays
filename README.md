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

### Option 1: Build from Source

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/SwitchAmongDisplays.git
   cd SwitchAmongDisplays
   ```

2. Open the project in Xcode:
   ```bash
   open SwitchAmongDisplays.xcodeproj
   ```

3. Build and run the app (⌘ + R)

### Option 2: Pre-built Binary

1. Download the latest release from [Releases](https://github.com/your-username/SwitchAmongDisplays/releases)
2. Unzip the file
3. Move `SwitchAmongDisplays.app` to your Applications folder

## Setup Instructions (Critical)

After installing, you **must** grant Accessibility permissions for the keyboard shortcut to work:

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Click the **+** button at the bottom of the list
3. Navigate to `/Applications` and select `SwitchAmongDisplays.app`
4. Check the box next to the app in the list

![Accessibility Permissions Setup](docs/permissions-setup.png)

> ⚠️ **Important:** If you don't see the app in the list:
> - Try moving the app to `/Applications` first
> - If still not visible, open Terminal and run:
>   ```bash
>   sudo chmod -R 755 /Applications/SwitchAmongDisplays.app
>   ```

## Usage

- Press **⌘ + ⇧ + D** (Command + Shift + D) to switch to the next display
- The app runs in the background with a menu bar icon (optional in future versions)
- To quit: Right-click the app in Dock and select "Quit"

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Shortcut not working | Verify Accessibility permissions are granted |
| Only cycles through some displays | Make sure all displays are detected in System Settings → Displays |
| App crashes on launch | Check Console.app for error logs |
| Cursor jumps but doesn't stay | May require restarting the app after display changes |

## Building for Development

```bash
# Clean build
xcodebuild clean

# Build for current platform
xcodebuild -scheme SwitchAmongDisplays -configuration Debug

# Run from command line
open ./build/Debug/SwitchAmongDisplays.app
```

## Contributing

Pull requests are welcome! Please open an issue first to discuss proposed changes.

## License

[MIT](LICENSE)