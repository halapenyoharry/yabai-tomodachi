#!/usr/bin/env swift

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var yabaiIsWorking: Bool = false
    var serviceSetupAttempted: Bool = false
    var yabaiPath: String = ""
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize status item first to prevent crashes
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        // Find yabai binary (bundled first, then system)
        findYabaiBinary()
        
        // Check if Yabai is working
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
        buildMenu()
        statusItem.menu = menu
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
        
        // Fall back to system yabai
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
        
        // Service Control
        menu.addItem(NSMenuItem(title: "Restart Yabai", action: #selector(restartYabai), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Stop Yabai", action: #selector(stopYabai), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Start Yabai", action: #selector(startYabai), keyEquivalent: ""))
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
        
        // Space/Layout Commands
        let layoutMenu = NSMenuItem(title: "Layout", action: nil, keyEquivalent: "")
        let layoutSubmenu = NSMenu()
        layoutSubmenu.addItem(NSMenuItem(title: "BSP (Tiling)", action: #selector(setBSP), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Float", action: #selector(setFloat), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Stack", action: #selector(setStack), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Rotate Layout 90°", action: #selector(rotateTree), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror X-Axis", action: #selector(mirrorX), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror Y-Axis", action: #selector(mirrorY), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Arrange Space (1 Top, Rest Bottom)", action: #selector(arrangeSpace), keyEquivalent: ""))
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
    }
    
    @objc func restartYabai() {
        runCommand("yabai --restart-service")
        showNotification("Yabai Restarted", "Yabai has been restarted")
    }
    
    @objc func stopYabai() {
        runCommand("yabai --stop-service")
        showNotification("Yabai Stopped", "Yabai has been stopped")
    }
    
    @objc func startYabai() {
        runCommand("yabai --start-service")
        showNotification("Yabai Started", "Yabai has been started")
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
        // Safety check - don't run commands if Yabai isn't working
        if !yabaiIsWorking {
            print("Warning: Attempting to run command while Yabai is not properly initialized: \(command)")
            checkYabaiInstallation()  // Try to fix it
            return
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
    
    func checkYabaiInstallation() {
        // Check if we found a yabai binary
        if yabaiPath.isEmpty {
            showYabaiInstallDialog("No yabai binary found (neither bundled nor system)")
            return
        }
        
        print("Using yabai at: \(yabaiPath)")
        
        // Check if service plist exists
        let plistPath = "\(NSHomeDirectory())/Library/LaunchAgents/com.koekeishiya.yabai.plist"
        if !FileManager.default.fileExists(atPath: plistPath) {
            print("Yabai service plist not found - showing setup instructions")
            showSimpleSetupInstructions()
            return
        }
        
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
            // Try to start the service
            setupYabaiService()
            return
        }
        
        // If the test succeeds, yabai is working
        if testTask.terminationStatus == 0 {
            print("Yabai is working properly!")
        } else {
            print("Yabai test failed with status: \(testTask.terminationStatus)")
            showSimpleSetupInstructions()
            return
        }
        
        // Yabai is working properly
        yabaiIsWorking = true
        print("Yabai is installed and working properly")
    }
    
    func setupYabaiService() {
        serviceSetupAttempted = true
        
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "Yabai Service Setup Needed"
            alert.informativeText = "Yabai is installed but the service isn't running.\n\nNote: This may require admin permissions. Would you like to try setting up the service?"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Try Setup")
            alert.addButton(withTitle: "Skip")
            
            if alert.runModal() == .alertFirstButtonReturn {
                self?.performServiceSetup()
            } else {
                self?.showManualSetupInstructions()
            }
        }
    }
    
    func performServiceSetup() {
        showNotification("Setting Up Yabai Service", "Configuring service silently...")
        
        // First try to install the service - suppress all output
        let installTask = Process()
        installTask.launchPath = "/bin/bash"
        installTask.arguments = ["-c", "'\(yabaiPath)' --install-service 2>/dev/null"]
        
        let pipe = Pipe()
        installTask.standardOutput = pipe
        installTask.standardError = pipe
        
        do {
            try installTask.run()
            installTask.waitUntilExit()
            
            // Check if service file was created successfully
            let plistPath = "\(NSHomeDirectory())/Library/LaunchAgents/com.koekeishiya.yabai.plist"
            if !FileManager.default.fileExists(atPath: plistPath) {
                print("Service installation failed - plist not created")
                showServiceSetupError("Service file could not be created")
                return
            }
        } catch {
            print("Failed to install service: \(error)")
            showServiceSetupError("Process execution failed: \(error)")
            return
        }
        
        // Create default config if it doesn't exist
        let configPath = "\(NSHomeDirectory())/.yabairc"
        if !FileManager.default.fileExists(atPath: configPath) {
            let defaultConfig = """
#!/usr/bin/env sh

# default layout (can be bsp, stack or float)
yabai -m config layout bsp

# new window spawns to the right if vertical split, or bottom if horizontal split
yabai -m config window_placement second_child

# padding
yabai -m config top_padding    12
yabai -m config bottom_padding 12
yabai -m config left_padding   12
yabai -m config right_padding  12
yabai -m config window_gap     12

# mouse settings
yabai -m config mouse_follows_focus          off
yabai -m config focus_follows_mouse          off
yabai -m config mouse_modifier               fn
yabai -m config mouse_action1                move
yabai -m config mouse_action2                resize

echo "yabai configuration loaded.."
"""
            do {
                try defaultConfig.write(toFile: configPath, atomically: true, encoding: .utf8)
                // Make it executable
                let chmod = Process()
                chmod.launchPath = "/bin/chmod"
                chmod.arguments = ["+x", configPath]
                try chmod.run()
                chmod.waitUntilExit()
            } catch {
                print("Failed to create default config: \(error)")
            }
        }
        
        // Now start the service - suppress output  
        let startTask = Process()
        startTask.launchPath = "/bin/bash"
        startTask.arguments = ["-c", "'\(yabaiPath)' --start-service 2>/dev/null"]
        
        do {
            try startTask.run()
            startTask.waitUntilExit()
            
            // Give it a moment to start
            Thread.sleep(forTimeInterval: 2.0)
            
            // Reset the flag to allow re-checking
            serviceSetupAttempted = false
            
            // Check if it's working now
            checkYabaiInstallation()
            
            if yabaiIsWorking {
                showNotification("Yabai Ready!", "Service configured and running successfully!")
            } else {
                showManualSetupInstructions()
            }
        } catch {
            print("Failed to start service: \(error)")
            showServiceSetupError("Failed to start service: \(error)")
        }
    }
    
    func showServiceSetupError(_ error: String) {
        serviceSetupAttempted = false  // Reset flag so user can try again
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Service Setup Failed"
            alert.informativeText = "Could not automatically set up Yabai service.\n\nError: \(error)\n\nYou may need to run the following commands manually in Terminal:\n\n1. sudo yabai --install-service\n2. yabai --start-service"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func showSimpleSetupInstructions() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Yabai Setup Needed"
            alert.informativeText = "yabai-tomodachi is ready! To enable window management, run these two commands in Terminal:\n\n1. sudo yabai --install-service\n2. yabai --start-service\n\nThen restart this app. The yabai binary is already installed with this app."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Copy Commands")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString("sudo yabai --install-service && yabai --start-service", forType: .string)
                
                let copied = NSAlert()
                copied.messageText = "Commands Copied!"
                copied.informativeText = "The commands have been copied to your clipboard. Paste them in Terminal."
                copied.addButton(withTitle: "OK")
                copied.runModal()
            }
        }
    }
    
    func showManualSetupInstructions() {
        showSimpleSetupInstructions()
    }
    
    func showYabaiInstallDialog(_ reason: String) {
        let alert = NSAlert()
        alert.messageText = "Yabai Not Working"
        alert.informativeText = "yabai-tomodachi needs Yabai to work!\n\nIssue: \(reason)\n\nWould you like to install/fix Yabai now?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Install Yabai")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            showNotification("Installing Yabai", "Installing Yabai silently in background...")
            
            // Install silently in background without opening Terminal
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let task = Process()
                task.launchPath = "/bin/bash"
                task.arguments = ["-c", "curl -fsSL https://raw.githubusercontent.com/halapenyoharry/yabai-tomodachi/main/install-yabai.sh | bash"]
                
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    
                    DispatchQueue.main.async {
                        if task.terminationStatus == 0 {
                            self?.showNotification("Yabai Installed", "Installation completed! Restarting app...")
                            // Restart the check process
                            self?.findYabaiBinary()
                            self?.checkYabaiInstallation()
                        } else {
                            self?.showYabaiInstallError(output)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.showYabaiInstallError("Installation failed: \(error)")
                    }
                }
            }
        }
    }
    
    func showYabaiInstallError(_ error: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Yabai Installation Error"
            alert.informativeText = "Could not install Yabai automatically.\n\nError: \(error)\n\nPlease install manually using Homebrew:\nbrew install koekeishiya/formulae/yabai"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()