# Agent Context & Handover Notes

**Last Updated:** Jan 31, 2026
**Current Branch:** `recovery/jules-update-v1.5`

## 🧠 Session Context
We are troubleshooting a macOS Accessibility/TCC "Ghosting" issue that appears primarily in macOS 26.2 (Tahoe beta/update). The standard Homebrew `yabai` binary cannot be granted permissions.

## 🛠 Critical Technical Workarounds
**The "Renamed Binary" Strategy:**
To bypass the corrupted TCC database entry for `yabai`, we use a unique binary name.
1.  **Manual Action Required:** The user/agent must create this copy manually for now:
    ```zsh
    sudo cp /opt/homebrew/bin/yabai /opt/homebrew/bin/yabai-tomodachi
    ```
2.  **App Logic:** `YabaiTomodachi.swift` has been updated to:
    -   Look for `yabai-tomodachi` *first*.
    -   Use `yabai-tomodachi` when resolving symlinks for the "Permissions Helper".
    -   Launch the service using this path.

## 🐛 Known Issues
-   **Issue #001 (Silent Failure):** If no yabai binary is found, or if it's installed but stopped, clicking "Start Yabai" fails silently with a false positive "Success" notification.
-   **macOS 26.0 vs 26.2:**
    -   **26.0 (MacBook/Tropy):** Works fine with standard `yabai`. Workaround is optional but safe.
    -   **26.2 (Mac Studio):** **REQUIRES** the workaround.

## 📋 Next Steps
1.  **Menu Redesign (Issue #10):** The current menu is cluttered. Needs grouping and clean up.
2.  **Fix Issue #001:** Add proper error handling for missing binaries/failed starts.
3.  **Verification:** Confirm the "renamed binary" fix works on the problematic Mac Studio.

## ⚡️ Quick Start for Agents
1.  `git checkout recovery/jules-update-v1.5`
2.  `./build-test-app.sh`
3.  Ensure `yabai` is installed (`brew install koekeishiya/formulae/yabai`).
4.  If on macOS 26.2+, run the `cp` command above.
