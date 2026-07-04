import AppKit
import SwiftUI

// MARK: - 快捷键转显示文本

func shortcutDisplayString(keyCode: Int, modifiers: Int) -> String {
    var result = ""
    let flags = NSEvent.ModifierFlags(rawValue: UInt(modifiers))

    if flags.contains(.control) { result += "⌃" }
    if flags.contains(.option) { result += "⌥" }
    if flags.contains(.shift) { result += "⇧" }
    if flags.contains(.command) { result += "⌘" }

    let keyMap: [UInt16: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5",
        24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
        30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P",
        37: "L", 38: "J", 40: "K", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".",
        49: "Space", 36: "↩", 53: "Esc",
        111: "F12", 109: "F7", 103: "F11",
        126: "↑", 125: "↓", 123: "←", 124: "→"
    ]
    result += keyMap[UInt16(keyCode)] ?? "?"
    return result
}

// MARK: - UserDefaults Keys

enum SettingsKey {
    static let hotkeyKeyCode = "hotkeyKeyCode"
    static let hotkeyModifiers = "hotkeyModifiers"
    static let isMonitoring = "isMonitoring"
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static let defaultKeyCode: Int = 2       // D
    static let defaultModifiers: Int = Int(
        NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    )

    private var eventMonitor: Any?
    private var statusItem: NSStatusItem?
    private weak var mainWindow: NSWindow?
    private var defaultsObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 注册默认值
        UserDefaults.standard.register(defaults: [
            SettingsKey.hotkeyKeyCode: Self.defaultKeyCode,
            SettingsKey.hotkeyModifiers: Self.defaultModifiers,
            SettingsKey.isMonitoring: true
        ])

        setupMenuBar()
        registerHotkey()

        // 监听 UserDefaults 变化（来自 SwiftUI @AppStorage 的修改）
        defaultsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.unregisterHotkey()
            self?.registerHotkey()
            self?.updateMenuBar()
        }

        // 延迟查找主窗口
        DispatchQueue.main.async { [weak self] in
            self?.findMainWindow()
        }
    }

    /// 查找主窗口并设为自身的 NSWindowDelegate
    func findMainWindow() {
        for window in NSApplication.shared.windows {
            // 跳过 Preferences/Settings 窗口和面板窗口
            if window.title == "Preferences" || window.title == "Settings" {
                continue
            }
            // 跳过标题栏为空的浮动窗口
            if window.styleMask.contains(.fullSizeContentView) && window.title.isEmpty {
                continue
            }
            mainWindow = window
            window.delegate = self
            break
        }
        // 回退：第一个可用窗口
        if mainWindow == nil, let first = NSApplication.shared.windows.first {
            mainWindow = first
            first.delegate = self
        }
    }

    /// 供外部设置主窗口引用
    func setMainWindow(_ window: NSWindow) {
        mainWindow = window
        window.delegate = self
    }

    // MARK: - 读取当前设置

    private var currentKeyCode: UInt16 {
        UInt16(UserDefaults.standard.integer(forKey: SettingsKey.hotkeyKeyCode))
    }

    private var currentModifiers: UInt {
        UInt(UserDefaults.standard.integer(forKey: SettingsKey.hotkeyModifiers))
    }

    private var isMonitoringEnabled: Bool {
        UserDefaults.standard.bool(forKey: SettingsKey.isMonitoring)
    }

    // MARK: - 快捷键注册

    private func registerHotkey() {
        guard isMonitoringEnabled else { return }

        let targetKeyCode = currentKeyCode
        let targetModifiers = currentModifiers

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let eventMods = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
            guard eventMods == targetModifiers, event.keyCode == targetKeyCode else { return }
            self?.switchToNextDisplay()
        }
    }

    private func unregisterHotkey() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    // MARK: - 显示器切换

    private func switchToNextDisplay() {
        let screens = NSScreen.screens
        guard !screens.isEmpty else { return }

        // 根据光标实际位置判断当前所在屏幕
        let mouseLocation = NSEvent.mouseLocation
        let currentScreen = screens.first(where: { $0.frame.contains(mouseLocation) })
            ?? NSScreen.main
            ?? screens[0]

        // 用 frame 比对找索引（更健壮，不依赖对象指针相等）
        guard let currentIndex = screens.firstIndex(where: { $0.frame.equalTo(currentScreen.frame) }) else { return }

        let nextIndex = (currentIndex + 1) % screens.count
        let nextScreen = screens[nextIndex]

        // 目标显示器在 NSScreen 坐标中的中心点（原点在主显示器左下角）
        let nsCenter = CGPoint(x: nextScreen.frame.midX, y: nextScreen.frame.midY)

        // 转换到 Quartz 全局坐标（原点在主显示器左上角，Y 向下）
        let mainHeight = CGDisplayBounds(CGMainDisplayID()).size.height
        let quartzPoint = CGPoint(x: nsCenter.x, y: mainHeight - nsCenter.y)

        // 用 AppleScript 通过 Accessibility API 移动光标（最底层，最可靠）
        let script = """
        tell application "System Events"
            set position of mouse location to {\(Int(quartzPoint.x)), \(Int(quartzPoint.y))}
        end tell
        """
        var scriptError: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&scriptError)
        if let err = scriptError {
            NSLog("SwitchAmongDisplays: AppleScript move error: \(err)")
        }

        // 短暂等待让光标移动稳定
        Thread.sleep(forTimeInterval: 0.05)

        // 左键单击转移焦点
        if let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                              mouseCursorPosition: quartzPoint, mouseButton: .left),
           let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                            mouseCursorPosition: quartzPoint, mouseButton: .left) {
            down.post(tap: .cghidEventTap)
            up.post(tap: .cghidEventTap)
        }
    }

    // MARK: - 菜单栏

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            let image = NSImage(systemSymbolName: "rectangle.on.rectangle", accessibilityDescription: "Switch Among Displays")
            image?.size = NSSize(width: 16, height: 16)
            button.image = image
        }
        updateMenuBar()
    }

    private func updateMenuBar() {
        let menu = NSMenu()

        let showItem = NSMenuItem(title: "显示主窗口", action: #selector(showMainWindow), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        let enabled = isMonitoringEnabled
        let toggleTitle = enabled ? "✓ 启用切换" : "  启用切换"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleMonitoring), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let shortcutText = shortcutDisplayString(keyCode: Int(currentKeyCode), modifiers: Int(currentModifiers))
        let shortcutItem = NSMenuItem(title: "快捷键: \(shortcutText)", action: nil, keyEquivalent: "")
        shortcutItem.isEnabled = false
        menu.addItem(shortcutItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func showMainWindow() {
        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc private func toggleMonitoring() {
        let current = UserDefaults.standard.bool(forKey: SettingsKey.isMonitoring)
        UserDefaults.standard.set(!current, forKey: SettingsKey.isMonitoring)
    }

    @objc private func quitApp() {
        unregisterHotkey()
        NSApplication.shared.terminate(nil)
    }

    // MARK: - NSWindowDelegate — 关闭窗口时隐藏而非退出

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterHotkey()
        if let observer = defaultsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
