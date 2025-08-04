#!/usr/bin/env swift

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if Yabai is installed
        checkYabaiInstallation()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            // For standalone script, try multiple icon locations
            let iconPaths = [
                Bundle.main.path(forResource: "YabaiTomodachi", ofType: "icns"),
                Bundle.main.bundlePath + "/Contents/Resources/YabaiTomodachi.icns",
                FileManager.default.currentDirectoryPath + "/YabaiTomodachi.icns"
            ]
            
            var iconLoaded = false
            for path in iconPaths.compactMap({ $0 }) {
                if let customIcon = NSImage(contentsOfFile: path) {
                    customIcon.size = NSSize(width: 18, height: 18)
                    button.image = customIcon
                    iconLoaded = true
                    break
                }
            }
            
            if !iconLoaded {
                button.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: "Yabai")
            }
        }
        
        let menu = NSMenu()
        
        // Service Control
        menu.addItem(NSMenuItem(title: "🔄 Restart Yabai", action: #selector(restartYabai), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "⏹ Stop Yabai", action: #selector(stopYabai), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "▶️ Start Yabai", action: #selector(startYabai), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Window Commands
        let windowMenu = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        let windowSubmenu = NSMenu()
        windowSubmenu.addItem(NSMenuItem(title: "Balance Windows", action: #selector(balanceWindows), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Float", action: #selector(toggleFloat), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Fullscreen", action: #selector(toggleFullscreen), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Split", action: #selector(toggleSplit), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Center Window", action: #selector(centerWindow), keyEquivalent: ""))
        windowMenu.submenu = windowSubmenu
        menu.addItem(windowMenu)
        
        // Space/Layout Commands
        let layoutMenu = NSMenuItem(title: "Layout", action: nil, keyEquivalent: "")
        let layoutSubmenu = NSMenu()
        layoutSubmenu.addItem(NSMenuItem(title: "BSP (Tiling)", action: #selector(setBSP), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Float", action: #selector(setFloat), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Stack", action: #selector(setStack), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Rotate Tree", action: #selector(rotateTree), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror X-Axis", action: #selector(mirrorX), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror Y-Axis", action: #selector(mirrorY), keyEquivalent: ""))
        layoutMenu.submenu = layoutSubmenu
        menu.addItem(layoutMenu)
        
        // Padding/Gaps
        let paddingMenu = NSMenuItem(title: "Padding", action: nil, keyEquivalent: "")
        let paddingSubmenu = NSMenu()
        paddingSubmenu.addItem(NSMenuItem(title: "Toggle Padding", action: #selector(togglePadding), keyEquivalent: ""))
        paddingSubmenu.addItem(NSMenuItem(title: "Toggle Gaps", action: #selector(toggleGaps), keyEquivalent: ""))
        paddingSubmenu.addItem(NSMenuItem(title: "Increase Gaps", action: #selector(increaseGaps), keyEquivalent: ""))
        paddingSubmenu.addItem(NSMenuItem(title: "Decrease Gaps", action: #selector(decreaseGaps), keyEquivalent: ""))
        paddingMenu.submenu = paddingSubmenu
        menu.addItem(paddingMenu)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Edit Config", action: #selector(editConfig), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Reload Config", action: #selector(reloadConfig), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Restart macOS Dock", action: #selector(restartDock), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func restartYabai() {
        runCommand("yabai --restart-service")
        // Ensure BSP mode after restart
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.runCommand("yabai -m config layout bsp")
        }
        showNotification("Yabai Restarted", "Yabai restarted in BSP mode")
    }
    
    @objc func stopYabai() {
        runCommand("yabai --stop-service")
        showNotification("Yabai Stopped", "Yabai has been stopped")
    }
    
    @objc func startYabai() {
        runCommand("yabai --start-service")
        // Give yabai a moment to start, then set BSP layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.runCommand("yabai -m config layout bsp")
            self.runCommand("yabai -m space --balance")
        }
        showNotification("Yabai Started", "Yabai started in BSP mode")
    }
    
    @objc func reloadConfig() {
        runCommand("yabai -m config debug_output on")
        runCommand("yabai --restart-service")
        showNotification("Config Reloaded", "Yabai configuration reloaded")
    }
    
    @objc func setBSP() {
        runCommand("yabai -m space --layout bsp")
        showNotification("Layout Changed", "Current space set to BSP")
    }
    
    @objc func setFloat() {
        runCommand("yabai -m space --layout float")
        showNotification("Layout Changed", "Current space set to Float")
    }
    
    @objc func setStack() {
        runCommand("yabai -m space --layout stack")
        showNotification("Layout Changed", "Current space set to Stack")
    }
    
    // Window Commands
    @objc func balanceWindows() {
        runCommand("yabai -m space --balance")
        showNotification("Windows Balanced", "All windows have been balanced")
    }
    
    @objc func toggleFloat() {
        runCommand("yabai -m window --toggle float")
        showNotification("Toggle Float", "Window float state toggled")
    }
    
    @objc func toggleFullscreen() {
        runCommand("yabai -m window --toggle native-fullscreen")
        showNotification("Toggle Fullscreen", "Window fullscreen state toggled")
    }
    
    @objc func toggleSplit() {
        runCommand("yabai -m window --toggle split")
        showNotification("Toggle Split", "Window split orientation toggled")
    }
    
    @objc func centerWindow() {
        // First make window float, then center it
        runCommand("yabai -m window --toggle float")
        runCommand("yabai -m window --grid 6:6:1:1:4:4")
        showNotification("Window Centered", "Window floated and centered")
    }
    
    // Layout Commands
    @objc func rotateTree() {
        runCommand("yabai -m space --rotate 90")
        showNotification("Tree Rotated", "Layout tree rotated 90 degrees")
    }
    
    @objc func mirrorX() {
        runCommand("yabai -m space --mirror x-axis")
        showNotification("Mirrored X", "Layout mirrored on X-axis")
    }
    
    @objc func mirrorY() {
        runCommand("yabai -m space --mirror y-axis")
        showNotification("Mirrored Y", "Layout mirrored on Y-axis")
    }
    
    // Padding Commands
    @objc func togglePadding() {
        runCommand("yabai -m space --toggle padding")
        showNotification("Toggle Padding", "Space padding toggled")
    }
    
    @objc func toggleGaps() {
        runCommand("yabai -m space --toggle gap")
        showNotification("Toggle Gaps", "Window gaps toggled")
    }
    
    @objc func increaseGaps() {
        runCommand("yabai -m space --gap rel:5")
        showNotification("Gaps Increased", "Window gaps increased by 5px")
    }
    
    @objc func decreaseGaps() {
        runCommand("yabai -m space --gap rel:-5")
        showNotification("Gaps Decreased", "Window gaps decreased by 5px")
    }
    
    @objc func restartDock() {
        runCommand("killall Dock")
        showNotification("Dock Restarted", "macOS Dock has been restarted")
    }
    
    @objc func editConfig() {
        // Use -t flag to open as text file, avoiding Gatekeeper issues
        runCommand("open -t ~/.yabairc")
        showNotification("Config Opened", "Yabai config opened in text editor")
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func runCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
    }
    
    func showNotification(_ title: String, _ body: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func checkYabaiInstallation() {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "which yabai"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            // Yabai not found
            let alert = NSAlert()
            alert.messageText = "Yabai Not Found"
            alert.informativeText = "Yabai-Tomodachi needs Yabai to work!\n\nWould you like to install Yabai now?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Install Yabai")
            alert.addButton(withTitle: "Later")
            
            if alert.runModal() == .alertFirstButtonReturn {
                // Open Terminal with install command
                let installScript = "curl -fsSL https://raw.githubusercontent.com/halapenyoharry/yabai-tomodachi/main/install-yabai.sh | bash"
                let appleScript = """
                tell application "Terminal"
                    do script "\(installScript)"
                    activate
                end tell
                """
                
                if let script = NSAppleScript(source: appleScript) {
                    var error: NSDictionary?
                    script.executeAndReturnError(&error)
                }
            }
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()