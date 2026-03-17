# Agent Context & Handover Notes

**Last Updated:** Mar 17, 2026
**Current Branch:** `main`

## Project State

v2.0.0 shipped with complete menu redesign, DMG distribution, and user-friendly UX. MCP server has 19 macOS native tools.

### Resolved Issues
- **Issue #001 (Silent Failure):** Fixed Mar 12, 2026. `startYabai()` now checks `isYabaiRunning()` after delay and shows appropriate success/failure notification.
- **Menu Redesign (Issue #10):** Completed in v2.0.0. Dynamic Start/Stop, layout radio selection, tools section, More submenu.

## Active Workarounds

**TCC "Renamed Binary" Strategy (macOS 26.2):**
macOS 26.2 has a TCC database regression where `yabai` cannot be granted Accessibility permissions. The app's `findYabaiBinary()` looks for `/opt/homebrew/bin/yabai-tomodachi` first. Users on 26.2 need:
```zsh
sudo cp /opt/homebrew/bin/yabai /opt/homebrew/bin/yabai-tomodachi
```
- macOS 26.0: Works fine with standard `yabai`, workaround optional
- macOS 26.2: **Requires** the workaround

## Architecture

- **Swift Menu Bar App** (`YabaiTomodachi.swift`) — main GUI, compiled with `swiftc`
- **MCP Server** (`src/index.ts`) — TypeScript, exposes yabai tools to AI
- **Xcode Project** (`Yabai-Tomodachi-xcode/`) — for building proper app bundles
- Two Swift sources exist: `src/YabaiRestarter.swift` (old) and `YabaiTomodachi.swift` (current v2.0)

## Quick Start
1. Ensure on `main` branch
2. Build: `swiftc YabaiTomodachi.swift -o yabai-tomodachi` or use Xcode project
3. MCP: `npm install && npm run build`
4. Ensure `yabai` is installed: `brew install koekeishiya/formulae/yabai`
5. On macOS 26.2+, run the `cp` command above
