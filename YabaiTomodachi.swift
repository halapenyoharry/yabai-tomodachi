#!/usr/bin/env swift

import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    var controlWindow: NSWindow?
    var yabaiIsWorking: Bool = false
    var yabaiPath: String = ""
    private let spacingStep = 1

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        findYabaiBinary()
        checkYabaiInstallation()

        if let button = statusItem.button {
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
        menu.delegate = self
        buildMenu()
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        buildMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        buildMenu()
    }

    func findYabaiBinary() {
        let bundledPaths = [
            Bundle.main.path(forResource: "yabai", ofType: ""),
            Bundle.main.bundlePath + "/Contents/MacOS/yabai",
            Bundle.main.bundlePath + "/Contents/Resources/yabai",
            FileManager.default.currentDirectoryPath + "/yabai-binary"
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

        // Prefer the TCC-bypass renamed binary when present
        let customPath = "/opt/homebrew/bin/yabai-tomodachi"
        if FileManager.default.fileExists(atPath: customPath) {
            yabaiPath = customPath
            print("Found custom yabai-tomodachi at: \(customPath)")
            return
        }

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

        yabaiPath = ""
        print("No yabai binary found")
    }

    func buildMenu() {
        menu.removeAllItems()

        // --- Start / Stop ---
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

        // --- Layout section ---
        let layoutHeader = NSMenuItem(title: "Layout", action: nil, keyEquivalent: "")
        layoutHeader.isEnabled = false
        menu.addItem(layoutHeader)

        let currentLayout = getCurrentLayout()

        let tilingItem = NSMenuItem(title: "Tiling", action: #selector(setBSP), keyEquivalent: "")
        tilingItem.state = (currentLayout == "bsp") ? .on : .off
        tilingItem.indentationLevel = 1
        menu.addItem(tilingItem)

        let floatingItem = NSMenuItem(title: "Floating", action: #selector(setFloat), keyEquivalent: "")
        floatingItem.state = (currentLayout == "float") ? .on : .off
        floatingItem.indentationLevel = 1
        menu.addItem(floatingItem)

        menu.addItem(NSMenuItem.separator())

        // --- Tools section ---
        let toolsHeader = NSMenuItem(title: "Tools", action: nil, keyEquivalent: "")
        toolsHeader.isEnabled = false
        menu.addItem(toolsHeader)

        let splitItem = NSMenuItem(title: "Toggle Window Split", action: #selector(toggleSplit), keyEquivalent: "")
        splitItem.indentationLevel = 1
        menu.addItem(splitItem)

        let floatWindowItem = NSMenuItem(title: "Float Window", action: #selector(floatSelectedWindow), keyEquivalent: "")
        floatWindowItem.state = isFocusedWindowFloating() ? .on : .off
        floatWindowItem.indentationLevel = 1
        menu.addItem(floatWindowItem)

        let padPlusItem = NSMenuItem(title: "Padding +", action: #selector(increasePadding), keyEquivalent: "")
        padPlusItem.indentationLevel = 1
        menu.addItem(padPlusItem)

        let padMinusItem = NSMenuItem(title: "Padding -", action: #selector(decreasePadding), keyEquivalent: "")
        padMinusItem.indentationLevel = 1
        menu.addItem(padMinusItem)

        let gapPlusItem = NSMenuItem(title: "Gaps +", action: #selector(increaseGaps), keyEquivalent: "")
        gapPlusItem.indentationLevel = 1
        menu.addItem(gapPlusItem)

        let gapMinusItem = NSMenuItem(title: "Gaps -", action: #selector(decreaseGaps), keyEquivalent: "")
        gapMinusItem.indentationLevel = 1
        menu.addItem(gapMinusItem)

        menu.addItem(NSMenuItem.separator())

        // --- More submenu (everything else) ---
        let moreMenu = NSMenuItem(title: "More", action: nil, keyEquivalent: "")
        let moreSubmenu = NSMenu()

        // Window actions
        let windowMenu = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        let windowSubmenu = NSMenu()
        windowSubmenu.addItem(NSMenuItem(title: "Balance Windows", action: #selector(balanceWindows), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Float", action: #selector(toggleFloat), keyEquivalent: ""))
        let toggleMaxItem = NSMenuItem(title: "Toggle Maximize", action: #selector(toggleMaximize), keyEquivalent: "f")
        toggleMaxItem.keyEquivalentModifierMask = [.command, .option]
        windowSubmenu.addItem(toggleMaxItem)
        windowSubmenu.addItem(NSMenuItem(title: "Toggle Native Fullscreen", action: #selector(toggleFullscreen), keyEquivalent: ""))
        windowSubmenu.addItem(NSMenuItem(title: "Center Window", action: #selector(centerWindow), keyEquivalent: ""))
        windowMenu.submenu = windowSubmenu
        moreSubmenu.addItem(windowMenu)

        // Advanced Layout
        let layoutMenu = NSMenuItem(title: "Advanced Layout", action: nil, keyEquivalent: "")
        let layoutSubmenu = NSMenu()
        layoutSubmenu.addItem(NSMenuItem(title: "Stack", action: #selector(setStack), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Rotate Layout 90°", action: #selector(rotateTree), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror X-Axis", action: #selector(mirrorX), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem(title: "Mirror Y-Axis", action: #selector(mirrorY), keyEquivalent: ""))
        layoutSubmenu.addItem(NSMenuItem.separator())
        layoutSubmenu.addItem(NSMenuItem(title: "Arrange Space (1 Top, Rest Bottom)", action: #selector(arrangeSpace), keyEquivalent: ""))
        layoutMenu.submenu = layoutSubmenu
        moreSubmenu.addItem(layoutMenu)

        moreSubmenu.addItem(NSMenuItem.separator())
        moreSubmenu.addItem(NSMenuItem(title: "Edit Config", action: #selector(editConfig), keyEquivalent: ""))
        moreSubmenu.addItem(NSMenuItem(title: "Reload Config", action: #selector(reloadConfig), keyEquivalent: ""))
        moreSubmenu.addItem(NSMenuItem(title: "Restart macOS Dock", action: #selector(restartDock), keyEquivalent: ""))
        moreSubmenu.addItem(NSMenuItem.separator())
        moreSubmenu.addItem(NSMenuItem(title: "Permissions Helper...", action: #selector(openPermissionsHelp), keyEquivalent: ""))

        moreMenu.submenu = moreSubmenu
        menu.addItem(moreMenu)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Show Controls...", action: #selector(toggleControlWindow), keyEquivalent: "k"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }

    @objc func toggleControlWindow() {
        if controlWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 200, height: 80),
                styleMask: [.titled, .closable, .utilityWindow, .hudWindow],
                backing: .buffered,
                defer: false
            )
            window.title = "Yabai Controls"
            window.center()
            window.isReleasedWhenClosed = false

            let stack = NSStackView()
            stack.orientation = .vertical
            stack.spacing = 10
            stack.edgeInsets = NSEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            stack.translatesAutoresizingMaskIntoConstraints = false
            window.contentView = stack

            let paddingRow = NSStackView()
            paddingRow.orientation = .horizontal
            let paddingLabel = NSTextField(labelWithString: "Padding")
            paddingLabel.font = .boldSystemFont(ofSize: 11)
            paddingLabel.textColor = .secondaryLabelColor
            let pMinus = NSButton(title: "-", target: self, action: #selector(decreasePadding))
            pMinus.bezelStyle = .rounded
            let pPlus = NSButton(title: "+", target: self, action: #selector(increasePadding))
            pPlus.bezelStyle = .rounded
            paddingRow.addArrangedSubview(paddingLabel)
            paddingRow.addArrangedSubview(NSView())
            paddingRow.addArrangedSubview(pMinus)
            paddingRow.addArrangedSubview(pPlus)

            let gapsRow = NSStackView()
            gapsRow.orientation = .horizontal
            let gapsLabel = NSTextField(labelWithString: "Gaps")
            gapsLabel.font = .boldSystemFont(ofSize: 11)
            gapsLabel.textColor = .secondaryLabelColor
            let gMinus = NSButton(title: "-", target: self, action: #selector(decreaseGaps))
            gMinus.bezelStyle = .rounded
            let gPlus = NSButton(title: "+", target: self, action: #selector(increaseGaps))
            gPlus.bezelStyle = .rounded
            gapsRow.addArrangedSubview(gapsLabel)
            gapsRow.addArrangedSubview(NSView())
            gapsRow.addArrangedSubview(gMinus)
            gapsRow.addArrangedSubview(gPlus)

            stack.addArrangedSubview(paddingRow)
            stack.addArrangedSubview(gapsRow)

            [paddingRow, gapsRow].forEach {
                $0.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
                $0.distribution = .fillProportionally
            }

            controlWindow = window
        }

        controlWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func isYabaiRunning() -> Bool {
        let task = Process()
        task.launchPath = "/usr/bin/pgrep"
        task.arguments = ["-x", "yabai"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    func isFocusedWindowFloating() -> Bool {
        guard !yabaiPath.isEmpty else { return false }
        guard let output = runCommandAndCapture("yabai -m query --windows --window") else { return false }
        return output.contains("\"is-floating\":true")
    }

    func getCurrentLayout() -> String {
        guard !yabaiPath.isEmpty else { return "unknown" }

        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "'\(yabaiPath)' -m query --spaces --space | grep '\"type\":\"bsp\"' > /dev/null && echo bsp || echo float"]

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

    @objc func restartYabai() {
        runCommand("yabai --restart-service")
        showNotification("Yabai Restarted", "Yabai has been restarted")
    }

    @objc func stopYabai() {
        print("Stopping Yabai Service...")
        runCommand("yabai --stop-service")

        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "launchctl stop com.koekeishiya.yabai"]
        try? task.run()
        task.waitUntilExit()

        let killTask = Process()
        killTask.launchPath = "/usr/bin/killall"
        killTask.arguments = ["yabai"]
        try? killTask.run()
        killTask.waitUntilExit()

        showNotification("Yabai Stopped", "Yabai service has been stopped")
        checkYabaiInstallation()
        buildMenu()
    }

    @objc func startYabai() {
        print("Starting Yabai Service...")
        runCommand("yabai --start-service")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.checkYabaiInstallation()
            self.buildMenu()
            if self.isYabaiRunning() {
                self.showNotification("Yabai Started", "Yabai service is running")
            } else {
                self.showNotification("Yabai Start Failed", "Could not start Yabai. Ensure it is installed and has Accessibility permissions.")
            }
        }
    }

    @objc func reloadConfig() {
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

    @objc func rotateTree() {
        runCommand("yabai -m space --rotate 90")
        showNotification("Layout Rotated", "Window layout rotated 90°")
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
        let scriptPath = NSHomeDirectory() + "/.local/bin/yabai-arrange-space"

        if !FileManager.default.fileExists(atPath: scriptPath) {
            let scriptContent = """
#!/usr/bin/env sh

# Arrange windows: one on top, rest on bottom splitting vertically
windows=$(yabai -m query --windows --space | jq -r '.[].id')
window_count=$(echo "$windows" | wc -l | tr -d ' ')

if [ "$window_count" -lt 2 ]; then
    echo "Need at least 2 windows to arrange"
    exit 1
fi

# Float all windows to reset the BSP tree
for window in $windows; do
    yabai -m window $window --toggle float
done

# Un-float in desired order: first on top, rest split below
first_window=$(echo "$windows" | sed -n '1p')
rest_windows=$(echo "$windows" | tail -n +2)

yabai -m window $first_window --toggle float
for window in $rest_windows; do
    yabai -m window $window --toggle float
done
"""
            let dir = NSHomeDirectory() + "/.local/bin"
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try? scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            runCommand("chmod +x \(scriptPath)")
        }

        runCommand(scriptPath)
        showNotification("Space Arranged", "Windows arranged: 1 on top, rest on bottom")
    }

    @objc func floatSelectedWindow() {
        runCommand("yabai -m window --toggle float")
        showNotification("Float Toggled", "Focused window float state toggled")
    }

    @objc func increasePadding() {
        let current = getConfigIntValue(key: "top_padding") ?? 0
        let next = current <= 0 ? spacingStep : current + spacingStep

        _ = runCommandAndCapture("yabai -m config top_padding \(next)")
        _ = runCommandAndCapture("yabai -m config bottom_padding \(next)")
        _ = runCommandAndCapture("yabai -m config left_padding \(next)")
        _ = runCommandAndCapture("yabai -m config right_padding \(next)")
        _ = runCommandAndCapture("yabai -m space --padding abs:\(next):\(next):\(next):\(next)")
        _ = runCommandAndCapture("yabai -m space --balance")
        showNotification("Padding Increased", "Edge padding set to \(next)px")
    }

    @objc func decreasePadding() {
        let current = getConfigIntValue(key: "top_padding") ?? 0
        let next = max(0, current - spacingStep)

        _ = runCommandAndCapture("yabai -m config top_padding \(next)")
        _ = runCommandAndCapture("yabai -m config bottom_padding \(next)")
        _ = runCommandAndCapture("yabai -m config left_padding \(next)")
        _ = runCommandAndCapture("yabai -m config right_padding \(next)")
        _ = runCommandAndCapture("yabai -m space --padding abs:\(next):\(next):\(next):\(next)")
        _ = runCommandAndCapture("yabai -m space --balance")
        showNotification("Padding Decreased", "Edge padding set to \(next)px")
    }

    @objc func increaseGaps() {
        let current = getConfigIntValue(key: "window_gap") ?? 0
        let next = current <= 0 ? spacingStep : current + spacingStep

        _ = runCommandAndCapture("yabai -m config window_gap \(next)")
        _ = runCommandAndCapture("yabai -m space --gap abs:\(next)")
        _ = runCommandAndCapture("yabai -m space --balance")
        showNotification("Gaps Increased", "Window gaps set to \(next)px")
    }

    @objc func decreaseGaps() {
        let current = getConfigIntValue(key: "window_gap") ?? 0
        let next = max(0, current - spacingStep)

        _ = runCommandAndCapture("yabai -m config window_gap \(next)")
        _ = runCommandAndCapture("yabai -m space --gap abs:\(next)")
        _ = runCommandAndCapture("yabai -m space --balance")
        showNotification("Gaps Decreased", "Window gaps set to \(next)px")
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
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
                return
            }
        }

        showNotification("Config Not Found", "Could not find .yabairc file to edit")
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    func runCommand(_ command: String) {
        let fullCommand = command.hasPrefix("/")
            ? command  // absolute path (e.g. chmod, scripts) — use as-is
            : command.replacingOccurrences(of: "yabai ", with: "'\(yabaiPath)' ")

        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", fullCommand]

        do {
            try task.run()
        } catch {
            print("Error running command: \(error)")
        }
    }

    func runCommandAndCapture(_ command: String) -> String? {
        let fullCommand = command.replacingOccurrences(of: "yabai ", with: "'\(yabaiPath)' ")

        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", fullCommand]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        do {
            try task.run()
            task.waitUntilExit()
            guard task.terminationStatus == 0 else { return nil }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    func getConfigIntValue(key: String) -> Int? {
        guard !yabaiPath.isEmpty else { return nil }
        guard let output = runCommandAndCapture("yabai -m config \(key)") else { return nil }
        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func showNotification(_ title: String, _ body: String) {
        print("[\(title)] \(body)")
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    @objc func openPermissionsHelp() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }

        var targetPath = "/opt/homebrew/bin/yabai-tomodachi"
        if !FileManager.default.fileExists(atPath: targetPath) {
            targetPath = yabaiPath.isEmpty ? "/opt/homebrew/bin/yabai" : yabaiPath
        }

        if let resolvedPath = try? FileManager.default.destinationOfSymbolicLink(atPath: targetPath) {
            if resolvedPath.hasPrefix("/") {
                targetPath = resolvedPath
            } else {
                let url = URL(fileURLWithPath: targetPath)
                targetPath = url.deletingLastPathComponent().appendingPathComponent(resolvedPath).path
            }
        }

        let fileURL = URL(fileURLWithPath: targetPath)
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
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
        guard !yabaiPath.isEmpty else {
            print("No yabai binary found (neither bundled nor system)")
            yabaiIsWorking = false
            return
        }

        print("Using yabai at: \(yabaiPath)")

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

        if testTask.terminationStatus == 0 {
            print("Yabai is working properly!")
            yabaiIsWorking = true
        } else {
            print("Yabai test failed with status: \(testTask.terminationStatus)")
            yabaiIsWorking = false
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
