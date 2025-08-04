# Future Features for yabai-tamadachi

## Next Version (v1.1)

### Quit Dialog with Preferences
When user quits yabai-tamadachi, show a dialog asking if they want to quit yabai too.

**Implementation Notes:**
```swift
enum QuitPreference: String {
    case alwaysAsk = "alwaysAsk"
    case neverAskJustTamadachi = "neverAskJustTamadachi" 
    case neverAskQuitBoth = "neverAskQuitBoth"
}

// In quit handler:
let preference = UserDefaults.standard.string(forKey: "quitPreference") ?? QuitPreference.alwaysAsk.rawValue

switch QuitPreference(rawValue: preference) {
case .alwaysAsk:
    // Show dialog with radio buttons
case .neverAskJustTamadachi:
    // Just quit yabai-tamadachi
case .neverAskQuitBoth:
    // Quit both yabai and yabai-tamadachi
}
```

**Dialog Design:**
```
"Also quit yabai?"
"yabai-tamadachi is closing. Would you like to quit yabai as well?"

○ Always ask me
○ Don't ask again, just quit yabai-tamadachi
○ Don't ask again, always quit both

[Quit yabai-tamadachi only] [Quit both]
```

## Long Term Goals

### Remove Emojis from Menu
- Make the menu bar more professional
- Keep the friendly tamadachi icon but remove emojis from menu items

### Expose Yabai Hotkeys
- Show keyboard shortcuts in the menu
- Help users learn to use yabai directly
- Maybe add a "Hotkeys" menu item with common shortcuts

### Check for Updates
- Check GitHub releases for new versions
- Notify user when update available
- Possibly auto-update with user permission

### Demo Videos
1. **yabai capabilities video** - Show what yabai can do and how yabai-tamadachi makes it accessible
2. **Claude + MCP video** - Demonstrate AI noticing user patterns and creating zen window arrangements

### Padding Improvement
- Current padding toggle might not be visible enough
- Consider adding visual indicator of current padding state
- Maybe show padding value in menu

## Technical Debt

### Code Organization
- Consider splitting YabaiRestarter.swift into multiple files
- Add proper error handling for all yabai commands
- Add unit tests for core functionality

### MCP Server Integration
- Document MCP server setup better
- Add more intelligent window arrangement tools
- Create presets for common workflows