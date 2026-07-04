## Setting Up SwitchAmongDisplays: Step-by-Step Guide

### Why This App Needs Special Permissions

SwitchAmongDisplays requires **Accessibility Permissions** because it:

- Listens for global keyboard shortcuts (Command+Shift+D)
- Moves the mouse cursor between displays programmatically
- Needs to interact with system-level display APIs

Without these permissions, the keyboard shortcut **will not work**.

### Complete Setup Process

#### 1. Install the Application

✅ **If you built from source**:
- Run the app once from Xcode (⌘+R)
- The app will appear in your Dock during testing

✅ **If using pre-built binary**:
- Move `SwitchAmongDisplays.app` to `/Applications` folder

#### 2. Grant Accessibility Permissions

🔒 **Critical Step - Must be completed**:

1. Open **System Settings** (Apple menu → System Settings)
2. Go to **Privacy & Security** → **Accessibility**
   ![](permissions-step1.png)
3. Click the **+** button at the bottom
   ![](permissions-step2.png)
4. Navigate to:
   - **If built from Xcode**: `~/Library/Developer/Xcode/DerivedData/` → find the app
   - **If installed in Applications**: `/Applications` → select `SwitchAmongDisplays.app`
5. Select the app and click **Open**
6. Check the box next to the app name
   ![](permissions-step3.png)

> 💡 **Troubleshooting Tip**: If the app doesn't appear in the list:
> ```bash
> sudo chmod -R 755 /Applications/SwitchAmongDisplays.app
> ```

#### 3. Verify Installation

After granting permissions:

1. Press **⌘ + ⇧ + D** (Command + Shift + D)
2. Your cursor should immediately jump to the next display
3. Repeat to cycle through all connected displays

#### 4. Access Settings (Optional)

To view application information:

1. Click the app in your Dock
2. Go to **Application → Settings** in the menu bar
3. View shortcut information and accessibility status

### Why This Setup is Necessary

macOS security model requires explicit permission for apps that:
- Monitor global keyboard events
- Control the mouse cursor
- Access display configuration

This protects against malicious applications that might try to capture your keystrokes or control your system.