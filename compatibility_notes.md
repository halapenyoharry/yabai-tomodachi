# OS Compatibility Notes

## macOS 26 (Tahoe) Series

### Version 26.0
- **Status:** Stable.
- **TCC/Accessibility:** Standard `yabai` binary is recognized correctly in System Settings.
- **Workaround:** Not strictly required, but `yabai-tomodachi` binary renaming works fine here too.

### Version 26.2 (Current Beta/Release)
- **Status:** Critical Issues (TCC Ghosting).
- **TCC/Accessibility:** A regression in 26.2 seems to cause "Ghosting" where the `yabai` binary (especially if updated via Homebrew) cannot be granted permissions. The entry appears but toggling it has no effect, or it disappears.
- **Workaround:** Renaming the binary to a unique name (e.g., `yabai-tomodachi`) forces macOS to treat it as a new application, bypassing the corrupted TCC database state. This is the **required fix** for 26.2 users.

## Testing Matrix
- [x] macOS 26.0 (MacBook / Tropy) - **PASSED**
- [ ] macOS 26.2 (Mac Studio) - **PENDING VERIFICATION**
