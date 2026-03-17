# yabai-tomodachi

<p align="center">Window tiling for everyone on macOS.</p>

<p align="center">
  <img src="assets/installer-welcome-message.rtfd/icon_128x128.png" width="256" height="256" alt="yabai-tomodachi icon">
</p>

<p align="center">
  A friendly menu bar companion that brings the power of <a href="https://github.com/koekeishiya/yabai">yabai</a> tiling to anyone — no terminal required.
</p>

---

## What is this?

macOS doesn't have real window tiling. Pop!_OS has it. Windows has it. Mac users get... drag to edges.

[yabai](https://github.com/koekeishiya/yabai) fixes this — it's the most powerful tiling window manager for macOS. But it's a command-line tool, and most people shouldn't need a terminal to tile their windows.

**Yabai Tomodachi bridges that gap.** It's a menu bar app that gives you point-and-click access to yabai's best features:

- **Tiling / Floating** layout toggle with live status
- **Float individual windows** in and out of tiling (with status indicator)
- **Toggle window splits**, adjust **padding** and **gaps**
- **Quick Controls panel** for real-time spacing adjustments
- Advanced options: rotate layouts, mirror axes, stack mode, and more

## Install

**Download the latest [DMG from Releases](https://github.com/halapenyoharry/yabai-tomodachi/releases).**

1. Open the DMG
2. Drag `Yabai-Tomodachi.app` to Applications
3. If you need yabai, double-click `Install Yabai.command` in the DMG
4. Launch the app — it appears in your menu bar
5. **If macOS says it "can't be opened" or "cannot be verified":** this is normal for apps not notarized by Apple. Open Terminal and run:
   ```
   xattr -cr /Applications/Yabai-Tomodachi.app
   ```
   Then open the app again. Alternatively: System Settings > Privacy & Security > "Open Anyway".

### Requirements

- macOS 12.0+ (Monterey or later)
- [yabai](https://github.com/koekeishiya/yabai) (installed via Homebrew — the DMG includes a helper)

### Build from source

```bash
git clone https://github.com/halapenyoharry/yabai-tomodachi.git
cd yabai-tomodachi
bash build-dmg.sh        # builds the full DMG
# or for quick dev builds:
bash build-test-app.sh   # builds just the app bundle
```

## AI Integration (MCP Server)

Yabai Tomodachi includes an MCP server that lets Claude control your windows through natural language.

```bash
npm install && npm run build
```

Add to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "yabai-tomodachi": {
      "command": "node",
      "args": ["/path/to/yabai-tomodachi/dist/index.js"]
    }
  }
}
```

Then ask Claude things like:
- "Set up my coding workspace"
- "Float this window and center it"
- "Move all browsers to space 2"
- "Balance all my windows"

### MCP Tools

**Query:** `query_spaces`, `query_windows`, `query_displays`
**Windows:** `focus_window`, `move_window_to_space`, `resize_window`, `toggle_window_property`
**Spaces:** `create_space`, `destroy_space`, `label_space`, `set_space_layout`, `focus_space`

## A tribute to yabai

[yabai](https://github.com/koekeishiya/yabai) by [koekeishiya](https://github.com/koekeishiya) is a masterpiece. It transforms macOS into something it should have been all along — a proper tiling window manager that respects how people actually work. The engineering behind yabai is extraordinary: a single developer building and maintaining what Apple hasn't in over 20 years of macOS.

Yabai Tomodachi exists because yabai deserves a wider audience. The power shouldn't be limited to people comfortable with dotfiles and shell commands. Every Mac user who's ever wrestled with overlapping windows deserves to experience what tiling feels like.

## For contributors and developers

This project has ambitious long-term goals. Today we're a companion app. Tomorrow we want to be **the** way people experience tiling on macOS.

The roadmap includes:
- **Native tiling engine** — building our own window management layer, potentially combining Apple's built-in tiling APIs (macOS Sequoia+) with the deep control that yabai pioneered
- **Visual layout designer** — drag-and-drop workspace layouts
- **Keyboard shortcut manager** — built-in hotkey configuration without needing skhd
- **Workspace presets** — save and restore window arrangements per project
- **First-launch onboarding** — zero-config tiling for people who've never heard of a window manager

We're building on the shoulders of a giant. If you're interested in macOS window management, Accessibility APIs, or making power tools accessible — we'd love your help.

## Ecosystem

- **[yabai](https://github.com/koekeishiya/yabai)** — the tiling window manager this all builds on
- **[skhd](https://github.com/koekeishiya/skhd)** — hotkey daemon by koekeishiya
- **[Stackline](https://github.com/AdamWagner/stackline)** — visual stack indicators
- **[YabaiIndicator](https://github.com/xiamaz/YabaiIndicator)** — menu bar space indicator

## License

MIT — same as yabai.

---

*Tomodachi (友達) means "friend" in Japanese. This project aims to be a helpful friend to both yabai and its users.*
