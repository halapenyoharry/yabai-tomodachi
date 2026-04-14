#!/usr/bin/env swift

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var yabaiIsWorking: Bool = false
    var yabaiPath: String = ""
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize status item first to prevent crashes
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Find yabai binary (bundled first, then system)
        findYabaiBinary()
        
        // Check if Yabai is working (non-blocking)
        checkYabaiInstallation()
        
        if let button = statusItem.button {
            // Try multiple icon locations for YabaiTomodachi
            let iconPaths = [
                Bundle.main.path(forResource: "YabaiTomodachi", ofType: "icns"),
                Bundle.main.bundlePath + "/Contents/Resources/YabaiTomodachi.icns",
                FileManager.default.currentDirectoryPath + "/icons/YabaiTomodachi.icns"
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
                button.image = NSImage(systemSymbolName: "arrow.triangle.2.circlepath", accessibilityDescription: "yabai-tomodachi")
            }
        }
        
        menu = NSMenu()
        menu.delegate = self // Set delegate so we can update before opening
        buildMenu()
        statusItem.menu = menu
    }
    
    // NSMenuDelegate method - called right before menu opens
    func menuNeedsUpdate(_ menu: NSMenu) {
        buildMenu()
    }
    
    func findYabaiBinary() {
        // First check for bundled yabai binary
        let bundledPaths = [
            Bundle.main.path(forResource: "yabai", ofType: ""),
            Bundle.main.bundlePath + "/Contents/MacOS/yabai",
            Bundle.main.bundlePath + "/Contents/Resources/yabai",
            FileManager.default.currentDirectoryPath + "/yabai-binary"  // For development
        ]
        
        print("Looking for yabai binary...")
        print("Bundle path: \(Bundle.main.bundlePath)")
        
        for path in bundledPaths.compactMap({ $0 }) {
            print("Checking path: \(path)")
            if FileManager.default.fileExists(atPath: path) {
                yabaiPath = path
                print("Found bundled yabai at: \(path)")
                return
            }
        }
        
        // Check for our custom 'yabai-tomodachi' binary first
        // This is used to bypass TCC/Accessibility issues with the standard 'yabai' binary
        let customPath = "/opt/homebrew/bin/yabai-tomodachi"
        if FileManager.default.fileExists(atPath: customPath) {
            yabaiPath = customPath
            print("Found custom yabai-tomodachi at: \(customPath)")
            return
        }
        
        // Fall back to system yabai
        // Explicitly check common Homebrew paths first (better than `which` in GUI apps)
        let commonPaths = [
            "/opt/homebrew/bin/yabai",
            "/usr/local/bin/yabai",
            "/usr/bin/yabai"
        ]
        
        for path in commonPaths {
             if FileManager.default.fileExists(atPath: path) {
                yabaiPath = path
                print("Found system yabai at: \(path)")
                return
            }
        }

        let whichTask = Process()
        whichTask.launchPath = "/bin/bash"
        whichTask.arguments = ["-c", "which yabai"]
        
        let whichPipe = Pipe()
        whichTask.standardOutput = whichPipe
        whichTask.standardError = whichPipe
        
        do {
            try whichTask.run()
            whichTask.waitUntilExit()
            
            if whichTask.terminationStatus == 0 {
                let data = whichPipe.fileHandleForReading.readDataToEndOfFile()
                let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if !path.isEmpty {
                    yabaiPath = path
                    print("Found system yabai at: \(path)")
                    return
                }
            }
        } catch {
            print("Error finding system yabai: \(error)")
        }
        
        // No yabai found
        yabaiPath = ""
        print("No yabai binary found")
    }
    
    func buildMenu() {
        menu.removeAllItems()
        
        // Service Control - Dynamic Start/Stop
        // Add Service Status Item (Clickable to toggle)
        if isYabaiRunning() {
             let stopItem = NSMenuItem(title: "Stop Yabai", action: #selector(stopYabai), keyEquivalent: "")
             stopItem.image = NSImage(systemSymbolName: "stop.circle", accessibilityDescription: "Stop")
             menu.addItem(stopItem)
        } else {
             let startItem = NSMenuItem(title: "Start Yabai", action: #selector(startYabai), keyEquivalent: "")
             startItem.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "Start")
             menu.addItem(startItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Smart Layout Actions (Top Level)
        let currentLayout = getCurrentLayout() 
        if currentLayout == "bsp" {
            menu.addItem(NSMenuItem(title: "Switch to Float", action: #selector(setFloat), keyEquivalent: ""))
        } else if currentLayout == "float" {
            menu.addItem(NSMenuItem(title: "Switch to BSP", action: #selector(setBSP), keyEquivalent: ""))
        } else {
            // Default fallback if unknown or stack
            menu.addItem(NSMenuItem(title: "Switch to BSP", action: #selector(setBSP), keyEquivalent: ""))
        }

        menu.addItem(NSMenuItem(title: "Float Window...", action: #selector(floatSelectedWindow), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        // Window Commands
        let windowMenu = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        let windowSubmenu = NSMenu()
        windowSubmenu.addItem(NSMenuItem(title: "Balance Windows", action: #selector(balanceWindows), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Float", action: #selector(toggleFloat), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Split", action: #selector(toggleSplit), keyEquivalent: ""))
        let toggleMaxItem = NSMenuItem(title: "Toggle Maximize", action: #selector(toggleMaximize), keyEquivalent: "f")
        toggleMaxItem.keyEquivalentModifierMask = [.command, .option]
        windowSubmenu.addItem(toggleMaxItem)
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Native Fullscreen", action: #selector(toggleFullscreen), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Center Window", action: #selector(centerWindow), keyEquivalent: ""))
        windowMenu.submenu = windowSubmenu
        menu.addItem(windowMenu)
        
        // Layout Commands (Submenu for advanced stuff)
        let layoutMenu = NSMenuItem(title: "Advanced Layout", action: nil, keyEquivalent: "")
        let layoutSubmenu = NSMenu()
        layoutSubmenu.addItem(NSMenuItem(title: "Stack", action: #selector(setStack), keyEquivalent: "")) // Stack remains hidden in advanced
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Rotate Layout 90°", action: #selector(rotateTree), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror X-Axis", action: #selector(mirrorX), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror Y-Axis", action: #selector(mirrorY), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Arrange Space (1 Top, Rest Bottom)", action: #selector(arrangeSpace), keyEquivalent: ""))
        layoutMenu.submenu = layoutSubmenu
        menu.addItem(layoutMenu)
        
        menu.addItem(NSMenuItem.separator())

        // Options Submenu
        let optionsMenu = NSMenuItem(title: "Options", action: nil, keyEquivalent: "")
        let optionsSubmenu = NSMenu()
        
        // Edge Padding
        let paddingMenu = NSMenuItem(title: "Edge Padding", action: nil, keyEquivalent: "")
        let paddingSubmenu = NSMenu()
        paddingSubmenu.addItem(NSMenuItem(title: "Toggle Padding", action: #selector(togglePadding), keyEquivalent: ""))
        optionsSubmenu.addItem(paddingMenu)
        paddingMenu.submenu = paddingSubmenu // Nesting padding toggle inside "Edge Padding" submenu feels wrong, let's flatten it or group nicely
        
        // Re-doing Options Structure based on request
        optionsSubmenu.addItem(NSMenuItem(title: "Toggle Edge Padding", action: #selector(togglePadding), keyEquivalent: ""))
        optionsSubmenu.addItem(NSMenuItem(title: "Toggle Window Gaps", action: #selector(toggleGaps), keyEquivalent: ""))
        optionsSubmenu.addItem(NSMenuItem.separator())
        optionsSubmenu.addItem(NSMenuItem(title: "Increase Gaps", action: #selector(increaseGaps), keyEquivalent: ""))
        optionsSubmenu.addItem(NSMenuItem(title: "Decrease Gaps", action: #selector(decreaseGaps), keyEquivalent: ""))
        optionsSubmenu.addItem(NSMenuItem.separator())
        optionsSubmenu.addItem(NSMenuItem(title: "Edit Config", action: #selector(editConfig), keyEquivalent: ""))
        optionsSubmenu.addItem(NSMenuItem(title: "Reload Config", action: #selector(reloadConfig), keyEquivalent: ""))
        optionsSubmenu.addItem(NSMenuItem(title: "Restart macOS Dock", action: #selector(restartDock), keyEquivalent: ""))
        
        optionsSubmenu.addItem(NSMenuItem.separator())
        optionsSubmenu.addItem(NSMenuItem(title: "Permissions Helper...", action: #selector(openPermissionsHelp), keyEquivalent: ""))
        
        optionsMenu.submenu = optionsSubmenu
        menu.addItem(optionsMenu)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }
    
    // Helper to check if yabai is running
    func isYabaiRunning() -> Bool {
        let myPid = ProcessInfo.processInfo.processIdentifier
        let names = ["yabai", "yabai-tomodachi"]
        
        for name in names {
            let task = Process()
            task.launchPath = "/usr/bin/pgrep"
            task.arguments = ["-x", name]

            let pipe = Pipe()
            task.standardOutput = pipe

            do {
                try task.run()
                task.waitUntilExit()

                if task.terminationStatus == 0 {
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    if let output = String(data: data, encoding: .utf8) {
                        let pids = output.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                        for pidStr in pids {
                            if let pid = Int32(pidStr), pid != myPid {
                                return true
                            }
                        }
                    }
                }
            } catch {}
        }

        return false
    }

    // Helper to get current layout
    func getCurrentLayout() -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
         // Try checking only when yabai is accessible
        guard !yabaiPath.isEmpty else { return "unknown" }
        
        // Use full path to yabai if possible, or PATH
        // Assuming checkYabaiInstallation has run and yabaiPath is set or we use default lookup
        task.arguments = ["-c", "\(yabaiPath) -m query --spaces --space | grep '\"type\":\"bsp\"' > /dev/null && echo bsp || echo float"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "unknown"
        } catch {
            return "unknown"
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        buildMenu() // Rebuild menu every time it opens to show correct status/layout
    }

    
    @objc func stopYabai() {
        // Try standard service stop
        print("Stopping Yabai Service...")
        
        // Try multiple methods to ensure it dies
        runCommand("yabai --stop-service")
        
        // Also try direct launchctl if we know the service name
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "launchctl stop com.koekeishiya.yabai"]
        try? task.run()
        task.waitUntilExit()
        
        showNotification("Yabai Stopped", "Yabai service has been stopped")
        
        // Force immediate menu update
        checkYabaiInstallation()
        buildMenu()
    }
    
    @objc func startYabai() {
        // Try standard service start
        print("Starting Yabai Service...")
        runCommand("yabai --start-service")
        
        // Give it a second to spin up
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Force immediate menu update
            self?.checkYabaiInstallation()
            self?.buildMenu()
            self?.showNotification("Yabai Started", "Yabai service has been started")
        }
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
        runCommand("yabai -m window --grid 6:6:1:1:4:4")
        showNotification("Window Centered", "Window moved to center")
    }
    
    @objc func toggleMaximize() {
        runCommand("yabai -m window --toggle zoom-fullscreen")
        showNotification("Toggle Maximize", "Window maximize state toggled")
    }
    
    // Layout Commands
    @objc func rotateTree() {
        runCommand("yabai -m space --rotate 90")
        showNotification("Layout Rotated", "Window layout rotated 90° (only visible with multiple windows in BSP mode)")
    }
    
    @objc func mirrorX() {
        runCommand("yabai -m space --mirror x-axis")
        showNotification("Mirrored X", "Layout mirrored on X-axis")
    }
    
    @objc func mirrorY() {
        runCommand("yabai -m space --mirror y-axis")
        showNotification("Mirrored Y", "Layout mirrored on Y-axis")
    }
    
    @objc func arrangeSpace() {
        // Run the arrange space script
        let scriptPath = NSHomeDirectory() + "/.local/bin/yabai-arrange-space"
        
        // Check if script exists, if not create it
        if !FileManager.default.fileExists(atPath: scriptPath) {
            let scriptContent = """
#!/usr/bin/env sh

# Script to arrange windows: one on top, rest on bottom splitting vertically

# Get all windows in current space
windows=$(yabai -m query --windows --space | jq -r '.[].id')
window_count=$(echo "$windows" | wc -l | tr -d ' ')

if [ "$window_count" -lt 2 ]; then
    echo "Need at least 2 windows to arrange"
    exit 1
fi

# First, make all windows float to reset the BSP tree
for window in $windows; do
    yabai -m window $window --toggle float
done

# Now un-float them in the order we want
# First window
first_window=$(echo "$windows" | sed -n '1p')
yabai -m window $first_window --toggle float

# Second window - this will create the initial split
second_window=$(echo "$windows" | sed -n '2p')
yabai -m window $second_window --toggle float

# Check current split type and ensure it's horizontal
first_split=$(yabai -m query --windows --window $first_window | jq -r '."split-type"')
if [ "$first_split" = "vertical" ]; then
    yabai -m window $first_window --toggle split
fi

# Now add remaining windows - they should split vertically in the bottom section
remaining_windows=$(echo "$windows" | tail -n +3)
if [ -n "$remaining_windows" ]; then
    # Focus the second window so new windows attach to it
    yabai -m window $second_window --focus
    for window in $remaining_windows; do
        yabai -m window $window --toggle float
        # Warp to second window's area
        yabai -m window $window --warp $second_window
    done
fi

# Balance the space for even sizing
yabai -m space --balance

echo "Arranged $window_count windows: 1 on top, rest on bottom"
"""
            // Create .local/bin directory if it doesn't exist
            let binDir = NSHomeDirectory() + "/.local/bin"
            try? FileManager.default.createDirectory(atPath: binDir, withIntermediateDirectories: true)
            
            // Write the script
            try? scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            
            // Make it executable
            runCommand("chmod +x \(scriptPath)")
        }
        
        // Run the script
        runCommand(scriptPath)
        showNotification("Space Arranged", "Windows arranged: 1 on top, rest on bottom")
    }
    
    @objc func floatSelectedWindow() {
        // Run a script to select a window and float it
        // Since we can't easily do "click to select" without complicated cursor tracking in Swift alone
        // We will use the 'mouse' selector which applies to window under cursor if we bind it to a hotkey,
        // BUT for a menu item, the user has to click the menu, so 'mouse' might be the menu bar itself or nil.
        // BETTER APPROACH: Just float the currently focused window, OR 
        // prompt user "Focus the window you want to float, then press Enter" (clunky).
        
        // Alternative: Use `yabai -m query --windows` to list windows and show valid ones? Too complex for menu.
        // Let's stick to "Float FOCUSED Window" for now as it's the standard yabai pattern,
        // OR rely on "mouse" which often means "window under mouse when command runs".
        // When clicking menu, mouse is over menu. 
        // So let's implement the standard "Make Focused Window Float" for now.
        
        runCommand("yabai -m window --toggle float")
        showNotification("Float Toggled", "Focused window float state toggled")
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
        let home = NSHomeDirectory()
        let possiblePaths = [
            "\(home)/.yabairc",
            "\(home)/.config/yabai/yabairc"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                print("Opening config at: \(path)")
                NSWorkspace.shared.openFile(path)
                return
            }
        }
        
        showNotification("Config Not Found", "Could not find .yabairc file to edit")
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func runCommand(_ command: String) {
        // Always try to run the command, even if we think yabai isn't working.
        // The user knows best, and the command might fix the state (like starting the service).
        if !yabaiIsWorking {
            print("Notice: Running command while app thinks Yabai is not initialized: \(command)")
        }
        
        // Replace "yabai" with the actual path
        let fullCommand = command.replacingOccurrences(of: "yabai ", with: "'\(yabaiPath)' ")
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", fullCommand]
        
        do {
            try task.run()
        } catch {
            print("Error running command: \(error)")
            showNotification("Command Failed", "Error executing Yabai command")
        }
    }
    
    func showNotification(_ title: String, _ body: String) {
        // Print to console for debugging
        print("[\(title)] \(body)")
    }
    
    @objc func openPermissionsHelp() {
        // 1. Open System Settings -> Privacy & Security -> Accessibility
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
        
        // 2. Reveal yabai binary in Finder (Resolving Symlinks)
        // Prefer our custom binary if it exists, as it is likely the one running via launchd now
        var targetPath = "/opt/homebrew/bin/yabai-tomodachi"
        if !FileManager.default.fileExists(atPath: targetPath) {
             targetPath = yabaiPath.isEmpty ? "/opt/homebrew/bin/yabai" : yabaiPath
        }
        
        // Resolve symlink to get the real binary path (e.g., inside Cellar)
        // This is crucial because TCC often ignores symlinks
        if let resolvedPath = try? FileManager.default.destinationOfSymbolicLink(atPath: targetPath) {
             // destinationOfSymbolicLink returns a relative path if it was relative
             if resolvedPath.hasPrefix("/") {
                 targetPath = resolvedPath
             } else {
                 // Resolve relative path
                 let url = URL(fileURLWithPath: targetPath)
                 targetPath = url.deletingLastPathComponent().appendingPathComponent(resolvedPath).path
             }
        }
        
        let fileURL = URL(fileURLWithPath: targetPath)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        
        // 3. Show Instructions
        showPermissionInstructions(for: targetPath)
    }
    
    func showPermissionInstructions(for path: String) {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = """
        If 'yabai' does not appear in the Accessibility list:
        
        1. Find the highlighted 'yabai' file in the Finder window that just opened.
           (Located at: \(path))
        
        2. Drag and drop that file directly into the System Settings list.
        
        3. Ensure the toggle switch is ON.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Done")
        alert.runModal()
    }

    func checkYabaiInstallation() {
        // Check if we found a yabai binary
        if yabaiPath.isEmpty {
            print("No yabai binary found (neither bundled nor system)")
            yabaiIsWorking = false
            return
        }
        
        print("Using yabai at: \(yabaiPath)")
        
        // Skip rigid plist check. Just test if it works.
        // Users might use Homebrew services (homebrew.mxcl.yabai.plist) or run manually.
        
        // Simple test - just try to query without timeout
        let testTask = Process()
        testTask.launchPath = yabaiPath
        testTask.arguments = ["-m", "query", "--spaces"]
        
        let testPipe = Pipe()
        testTask.standardOutput = testPipe
        testTask.standardError = testPipe
        
        do {
            try testTask.run()
            testTask.waitUntilExit()
        } catch {
            print("Error testing yabai: \(error)")
            yabaiIsWorking = false
            return
        }
        
        // If the test succeeds, yabai is working
        if testTask.terminationStatus == 0 {
            print("Yabai is working properly!")
            yabaiIsWorking = true
        } else {
            print("Yabai test failed with status: \(testTask.terminationStatus)")
            yabaiIsWorking = false
            return
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()