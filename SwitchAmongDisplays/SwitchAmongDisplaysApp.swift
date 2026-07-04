//
//  SwitchAmongDisplaysApp.swift
//  SwitchAmongDisplays
//
//  Created by 梁子凡 on 7/4/26.
//

import SwiftUI

@main
struct SwitchAmongDisplaysApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 将主窗口代理设为 AppDelegate（实现关闭即隐藏）
                    DispatchQueue.main.async {
                        if let appDelegate = NSApp.delegate as? AppDelegate {
                            if let window = NSApplication.shared.windows.first {
                                appDelegate.setMainWindow(window)
                            }
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
        }
    }
}
