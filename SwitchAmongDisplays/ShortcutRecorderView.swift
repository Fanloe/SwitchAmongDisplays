import SwiftUI
import AppKit

// MARK: - SwiftUI 包装

struct ShortcutRecorderView: NSViewRepresentable {
    @Binding var keyCode: Int
    @Binding var modifiers: Int

    func makeNSView(context: Context) -> KeyRecorderNSView {
        let view = KeyRecorderNSView()
        view.keyCode = keyCode
        view.modifiers = modifiers
        view.onChange = { newKeyCode, newModifiers in
            keyCode = newKeyCode
            modifiers = newModifiers
        }
        return view
    }

    func updateNSView(_ nsView: KeyRecorderNSView, context: Context) {
        nsView.keyCode = keyCode
        nsView.modifiers = modifiers
    }
}

// MARK: - 自定义 NSView 捕获按键

class KeyRecorderNSView: NSView {
    var keyCode: Int = 2
    var modifiers: Int = 0
    var isRecording: Bool = false
    var onChange: ((Int, Int) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // 背景
        let bgColor: NSColor = isRecording
            ? NSColor.controlAccentColor.withAlphaComponent(0.15)
            : NSColor.controlBackgroundColor
        bgColor.setFill()
        let path = NSBezierPath(roundedRect: bounds, xRadius: 6, yRadius: 6)
        path.fill()

        // 边框
        let borderColor: NSColor = isRecording
            ? NSColor.controlAccentColor
            : NSColor.separatorColor
        borderColor.setStroke()
        path.lineWidth = isRecording ? 2 : 1
        path.stroke()

        // 文本
        let text: String
        let textColor: NSColor
        if isRecording {
            text = "按下新快捷键..."
            textColor = .secondaryLabelColor
        } else {
            text = shortcutDisplayString(keyCode: keyCode, modifiers: modifiers)
            textColor = .labelColor
        }

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: textColor
        ]
        let attrStr = NSAttributedString(string: text, attributes: attrs)
        let strSize = attrStr.size()
        let strRect = NSRect(
            x: (bounds.width - strSize.width) / 2,
            y: (bounds.height - strSize.height) / 2,
            width: strSize.width,
            height: strSize.height
        )
        attrStr.draw(in: strRect)
    }

    override func mouseDown(with event: NSEvent) {
        isRecording = true
        window?.makeFirstResponder(self)
        setNeedsDisplay(bounds)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        // ESC 取消录制
        if event.keyCode == 53 {
            isRecording = false
            setNeedsDisplay(bounds)
            return
        }

        // 只记录修饰键 + 有效按键（不允许只有修饰键）
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let validModifiers: NSEvent.ModifierFlags = [.command, .shift, .option, .control]
        let hasModifier = flags.intersection(validModifiers).isEmpty == false

        if hasModifier {
            keyCode = Int(event.keyCode)
            modifiers = Int(flags.rawValue)
            isRecording = false
            onChange?(keyCode, modifiers)
        }

        setNeedsDisplay(bounds)
    }

    override func flagsChanged(with event: NSEvent) {
        if isRecording {
            setNeedsDisplay(bounds)
        }
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: 160, height: 32)
    }
}
