// macOS native tool handlers — all use built-in macOS commands
import { execAsync } from "./utils.js";

function osascript(script: string): Promise<string> {
  // Escape for shell, run via osascript
  return execAsync(`osascript -e ${JSON.stringify(script)}`);
}

export async function handleMacosTool(
  name: string,
  args: Record<string, unknown>
): Promise<{ text: string } | null> {
  switch (name) {
    case "macos_get_volume": {
      const volume = await osascript("output volume of (get volume settings)");
      const muted = await osascript("output muted of (get volume settings)");
      return { text: `Volume: ${volume}%, Muted: ${muted}` };
    }

    case "macos_set_volume": {
      const level = Math.max(0, Math.min(100, args.level as number));
      await osascript(`set volume output volume ${level}`);
      return { text: `Volume set to ${level}%` };
    }

    case "macos_toggle_mute": {
      const currentMute = await osascript("output muted of (get volume settings)");
      const newState = currentMute.trim() === "true" ? "false" : "true";
      await osascript(`set volume output muted ${newState}`);
      return { text: `Mute ${newState === "true" ? "enabled" : "disabled"}` };
    }

    case "macos_now_playing": {
      try {
        const state = await osascript(
          'tell application "Music" to get player state as string'
        );
        if (state === "stopped") {
          return { text: "Music.app is stopped — nothing playing" };
        }
        const track = await osascript(
          'tell application "Music" to get name of current track'
        );
        const artist = await osascript(
          'tell application "Music" to get artist of current track'
        );
        const album = await osascript(
          'tell application "Music" to get album of current track'
        );
        return {
          text: `State: ${state}\nTrack: ${track}\nArtist: ${artist}\nAlbum: ${album}`,
        };
      } catch {
        return { text: "Music.app is not running" };
      }
    }

    case "macos_music_control": {
      const action = args.action as string;
      const actionMap: Record<string, string> = {
        play: "play",
        pause: "pause",
        playpause: "playpause",
        next: "next track",
        previous: "previous track",
      };
      const cmd = actionMap[action];
      if (!cmd) throw new Error(`Unknown action: ${action}`);
      await osascript(`tell application "Music" to ${cmd}`);
      return { text: `Music: ${action}` };
    }

    case "macos_get_frontmost_app": {
      const appName = await osascript(
        'tell application "System Events" to get name of first application process whose frontmost is true'
      );
      const bundleId = await osascript(
        'tell application "System Events" to get bundle identifier of first application process whose frontmost is true'
      );
      return { text: `App: ${appName}\nBundle ID: ${bundleId}` };
    }

    case "macos_launch_app": {
      const app = args.app as string;
      await osascript(`tell application "${app}" to activate`);
      return { text: `Launched ${app}` };
    }

    case "macos_quit_app": {
      const app = args.app as string;
      await osascript(`tell application "${app}" to quit`);
      return { text: `Quit ${app}` };
    }

    case "macos_list_running_apps": {
      const apps = await osascript(
        'tell application "System Events" to get name of every application process whose background only is false'
      );
      return { text: apps };
    }

    case "macos_toggle_dark_mode": {
      await osascript(
        'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
      );
      const newMode = await osascript(
        'tell application "System Events" to tell appearance preferences to get dark mode'
      );
      return { text: `Dark mode: ${newMode === "true" ? "on" : "off"}` };
    }

    case "macos_get_appearance": {
      const dark = await osascript(
        'tell application "System Events" to tell appearance preferences to get dark mode'
      );
      return { text: `Appearance: ${dark === "true" ? "dark" : "light"}` };
    }

    case "macos_toggle_dock_autohide": {
      const current = await execAsync(
        "defaults read com.apple.dock autohide"
      ).catch(() => "0");
      const newVal = current.trim() === "1" ? "false" : "true";
      await execAsync(`defaults write com.apple.dock autohide -bool ${newVal}`);
      await execAsync("killall Dock");
      return { text: `Dock auto-hide: ${newVal === "true" ? "on" : "off"}` };
    }

    case "macos_open_url": {
      const url = args.url as string;
      await execAsync(`open ${JSON.stringify(url)}`);
      return { text: `Opened ${url}` };
    }

    case "macos_get_battery": {
      try {
        const output = await execAsync(
          "pmset -g batt | grep -Eo '\\d+%|charging|discharging|charged|AC Power'"
        );
        return { text: output || "No battery information available (desktop Mac?)" };
      } catch {
        return { text: "No battery information available (desktop Mac?)" };
      }
    }

    case "macos_do_not_disturb": {
      try {
        const output = await execAsync(
          "defaults -currentHost read com.apple.notificationcenterui doNotDisturb 2>/dev/null || echo 0"
        );
        return {
          text: `Do Not Disturb: ${output.trim() === "1" ? "on" : "off"}`,
        };
      } catch {
        return { text: "Do Not Disturb: off" };
      }
    }

    case "macos_notification": {
      const title = args.title as string;
      const message = args.message as string;
      await osascript(
        `display notification "${message.replace(/"/g, '\\"')}" with title "${title.replace(/"/g, '\\"')}"`
      );
      return { text: `Notification sent: ${title}` };
    }

    case "macos_run_shortcut": {
      const shortcutName = args.name as string;
      let cmd = `shortcuts run ${JSON.stringify(shortcutName)}`;
      if (args.input) {
        cmd = `echo ${JSON.stringify(args.input as string)} | shortcuts run ${JSON.stringify(shortcutName)}`;
      }
      const output = await execAsync(cmd).catch((e: Error) => e.message);
      return { text: output || `Ran shortcut: ${shortcutName}` };
    }

    case "macos_list_shortcuts": {
      const output = await execAsync("shortcuts list");
      return { text: output || "No shortcuts found" };
    }

    case "macos_screen_info": {
      const output = await execAsync(
        "system_profiler SPDisplaysDataType 2>/dev/null | grep -A5 'Resolution\\|Display Type\\|Main Display'"
      );
      return { text: output || "Could not get display information" };
    }

    default:
      return null;
  }
}
