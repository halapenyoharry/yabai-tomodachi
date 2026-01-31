# Issue: Silent Failure when Starting Yabai without Installation

**Status:** Open  
**Priority:** High  
**Branch:** `recovery/jules-update-v1.5`  
**Created:** Jan 31, 2026

## Description
When the application is launched on a system where `yabai` is not installed (and thus not found by `findYabaiBinary()`), the "Start Yabai" menu item is still active. Clicking it results in a silent failure with a false positive success notification.

## Current Behavior
1. `findYabaiBinary()` sets `yabaiPath` to an empty string `""`.
2. `startYabai()` calls `runCommand("yabai --start-service")`.
3. `runCommand` replaces `"yabai "` with `'' ` (empty string literal).
4. Bash executes `'' --start-service`, which fails siliently (or logs to stderr which is not captured/shown).
5. `startYabai()` waits 1 second and unconditionally shows `showNotification("Yabai Started", "Yabai service has been started")`.

## Expected Behavior
1. **Detection:** The app should explicitly handle the case where `yabaiPath` is empty.
2. **UI Feedback:**
   - The menu item should either be disabled or disabled with a tooltip.
   - OR clicking it should trigger an alert: "Yabai Binary Not Found".
   - OR it should offer to install Yabai (though we moved away from auto-installers, a link to instructions is good).
3. **Notification:** "Yabai Started" should only appear if the service actually started (check exit code or `pgrep`).

## Steps to Reproduce
### Scenario A: Missing Binary
1. Uninstall `yabai` or run on a fresh machine (e.g. "tropy" environment).
2. Launch `Yabai-Tomodachi-Test.app`.
3. Click the menu bar icon.
4. Select "Start Yabai".
5. Result: "Yabai Started" notification appears, but nothing happens.

### Scenario B: Installed via Homebrew but Stopped
1. Install `yabai` via Homebrew (`brew install koekeishiya/formulae/yabai`).
2. Ensure service is stopped.
3. Launch `Yabai-Tomodachi-Test.app`.
4. Select "Start Yabai".
5. Result: Silent failure. No error message, Yabai does not start.
   - *Hypothesis:* The `yabai --start-service` command might be failing due to environment path issues (can't find `brew` or `launchctl` inside the app sandbox/environment) or permissions. The app fails to catch this failure.
