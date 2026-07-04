import SwiftUI
import AppKit

struct ContentView: View {
    @AppStorage(SettingsKey.hotkeyKeyCode) private var hotkeyKeyCode = AppDelegate.defaultKeyCode
    @AppStorage(SettingsKey.hotkeyModifiers) private var hotkeyModifiers = AppDelegate.defaultModifiers
    @AppStorage(SettingsKey.isMonitoring) private var isMonitoring = true

    var body: some View {
        VStack(spacing: 20) {
            // 标题
            VStack(spacing: 4) {
                Image(systemName: "rectangle.on.rectangle")
                    .font(.system(size: 32))
                    .foregroundStyle(.tint)
                Text("SwitchAmongDisplays")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Divider()

            // 快捷键设置
            VStack(alignment: .leading, spacing: 8) {
                Text("切换快捷键")
                    .font(.headline)
                Text("点击后按下新快捷键")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Spacer()
                    ShortcutRecorderView(
                        keyCode: $hotkeyKeyCode,
                        modifiers: $hotkeyModifiers
                    )
                    Spacer()
                }
            }

            // 启用/禁用
            Toggle(isOn: $isMonitoring) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("启用切换")
                        .font(.headline)
                    Text(isMonitoring ? "快捷键已激活" : "快捷键已暂停")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .toggleStyle(.switch)

            Divider()

            // 权限设置
            Button(action: {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }) {
                Label("打开辅助功能设置", systemImage: "lock.shield")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
        .padding(24)
        .frame(width: 320, height: 320)
    }
}

#Preview {
    ContentView()
}
