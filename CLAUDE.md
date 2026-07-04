# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwitchAmongDisplays is a macOS utility app that moves the cursor to the next display when a configurable global hotkey is pressed. It is a SwiftUI + AppKit hybrid app targeting macOS 14+, running in the menu bar.

## Build & Run

This is an Xcode project (not Swift Package Manager). The scheme is `SwitchAmongDisplays`.

```bash
# Open in Xcode
open SwitchAmongDisplays.xcodeproj

# Build from command line
xcodebuild -scheme SwitchAmongDisplays -configuration Debug

# Run a specific test target
xcodebuild test -scheme SwitchAmongDisplays -only-testing:SwitchAmongDisplaysTests

# Run a single test by name
xcodebuild test -scheme SwitchAmongDisplays -only-testing:SwitchAmongDisplaysTests/SwitchAmongDisplaysTests/example
```

Tests use the **Swift Testing** framework (`import Testing`, `@Test`), not XCTest.

## Architecture

- **`SwitchAmongDisplaysApp.swift`** — `@main` entry point. Uses `@NSApplicationDelegateAdaptor` to bridge the AppKit `AppDelegate`. Declares two scenes: `WindowGroup` (main window, `.hiddenTitleBar`, fixed size) and `Settings` (preferences window). Sets the AppDelegate as window delegate via `.onAppear`.
- **`AppDelegate.swift`** — Core logic hub:
  - **Hotkey management**: dynamic `registerHotkey()` / `unregisterHotkey()` using `NSEvent.addGlobalMonitorForEvents` / `removeMonitor`. Reads settings from `UserDefaults`.
  - **Display switching**: `switchToNextDisplay()` reads `NSScreen.screens`, finds current via `NSScreen.main`, and calls `CGDisplayMoveCursorToPoint` on the next one (modulo wrap).
  - **Menu bar**: `NSStatusItem` with `NSMenu` (show window, toggle monitoring, quit). Updated when settings change.
  - **Window delegate**: `windowShouldClose` returns `false` and calls `orderOut(nil)` to hide rather than quit.
  - **Settings observation**: listens to `UserDefaults.didChangeNotification` to re-register hotkey when SwiftUI changes settings via `@AppStorage`.
  - Also exposes `shortcutDisplayString(keyCode:modifiers:)` and `SettingsKey` enum for cross-file use.
- **`ShortcutRecorderView.swift`** — Custom hotkey input via `NSViewRepresentable`. Wraps `KeyRecorderNSView` which overrides `keyDown(with:)` to capture modifier flags + key code. Click-to-record, ESC cancels. Accepts `@Binding var keyCode: Int` and `@Binding var modifiers: Int`.
- **`ContentView.swift`** — Main window UI. Uses `@AppStorage` for all three settings (no `@EnvironmentObject`). Contains: shortcut recorder, enable/disable toggle, accessibility settings button.
- **`SettingsView.swift`** — Preferences window UI (⌘+,). Shows current shortcut, permission instructions, about info.

## Data Flow

Settings are stored in `UserDefaults` via `@AppStorage` in SwiftUI views. `AppDelegate` observes `UserDefaults.didChangeNotification` to react to changes. No custom ObservableObject needed — avoids `@NSApplicationDelegateAdaptor` state-sharing issues.

## Permissions

The app requires **Accessibility** permissions to function. The entitlements file has App Sandbox enabled. When running from Xcode, the built binary lives under `~/Library/Developer/Xcode/DerivedData/` — that path must be added to Accessibility, not the `.xcodeproj`.

## Key Implementation Notes

- `switchToNextDisplay()` uses `NSScreen.main` to find the current screen and wraps around with modulo.
- The global monitor only fires with Accessibility permissions; no runtime permission check in code.
- Hotkey is configurable via the main window UI, persisted in `UserDefaults` (`hotkeyKeyCode`, `hotkeyModifiers`, `isMonitoring`).
- Closing the main window hides it instead of quitting; access via menu bar icon → "显示主窗口".
- `ISOLATED_MODIFIERS`: the hotkey must include at least one modifier (⌘⇧⌥⌃) to be registered.
