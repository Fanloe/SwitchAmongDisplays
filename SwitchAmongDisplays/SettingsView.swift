import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Shortcut Information")) {
                Text("Current shortcut: Command + Shift + D")
                    .font(.headline)

                Text("To change this shortcut, you need to modify the source code.\nSee README.md for instructions.")
                    .font(.body)
            }

            Section(header: Text("Accessibility Permissions")) {
                Text("Required for keyboard shortcut to work.\nGo to System Settings > Privacy & Security > Accessibility to grant permissions.")
            }

            Section(header: Text("About")) {
                Text("SwitchAmongDisplays v1.0\n© 2026 梁子凡")
                Link("View on GitHub", destination: URL(string: "https://github.com/your-username/SwitchAmongDisplays")!)
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
        .navigationTitle("Preferences")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}