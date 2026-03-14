// macOS native tools — no additional installs required
// Uses osascript (AppleScript/JXA), defaults, and built-in commands

export const macosToolDefinitions = [
  {
    name: "macos_get_volume",
    description: "Get the current system volume level (0-100) and mute state",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_set_volume",
    description: "Set the system volume level",
    inputSchema: {
      type: "object" as const,
      properties: {
        level: {
          type: "number",
          description: "Volume level (0-100)",
        },
      },
      required: ["level"],
    },
  },
  {
    name: "macos_toggle_mute",
    description: "Toggle system audio mute on/off",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_now_playing",
    description: "Get the currently playing track from Music.app (artist, track, album, state)",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_music_control",
    description: "Control Music.app playback",
    inputSchema: {
      type: "object" as const,
      properties: {
        action: {
          type: "string",
          enum: ["play", "pause", "playpause", "next", "previous"],
          description: "Playback action",
        },
      },
      required: ["action"],
    },
  },
  {
    name: "macos_get_frontmost_app",
    description: "Get the name and bundle ID of the frontmost application",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_launch_app",
    description: "Launch or activate an application by name",
    inputSchema: {
      type: "object" as const,
      properties: {
        app: {
          type: "string",
          description: "Application name (e.g. 'Safari', 'Terminal', 'Finder')",
        },
      },
      required: ["app"],
    },
  },
  {
    name: "macos_quit_app",
    description: "Quit an application by name",
    inputSchema: {
      type: "object" as const,
      properties: {
        app: {
          type: "string",
          description: "Application name to quit",
        },
      },
      required: ["app"],
    },
  },
  {
    name: "macos_list_running_apps",
    description: "List all currently running applications",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_toggle_dark_mode",
    description: "Toggle macOS dark mode on/off and return the new state",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_get_appearance",
    description: "Get current macOS appearance (dark or light mode)",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_toggle_dock_autohide",
    description: "Toggle Dock auto-hide on/off",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_open_url",
    description: "Open a URL in the default browser",
    inputSchema: {
      type: "object" as const,
      properties: {
        url: {
          type: "string",
          description: "URL to open",
        },
      },
      required: ["url"],
    },
  },
  {
    name: "macos_get_battery",
    description: "Get battery level and charging state (laptops only)",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_do_not_disturb",
    description: "Get the current Do Not Disturb / Focus status",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_notification",
    description: "Send a macOS notification",
    inputSchema: {
      type: "object" as const,
      properties: {
        title: {
          type: "string",
          description: "Notification title",
        },
        message: {
          type: "string",
          description: "Notification body text",
        },
      },
      required: ["title", "message"],
    },
  },
  {
    name: "macos_run_shortcut",
    description: "Run a Shortcuts.app shortcut by name",
    inputSchema: {
      type: "object" as const,
      properties: {
        name: {
          type: "string",
          description: "Name of the shortcut to run",
        },
        input: {
          type: "string",
          description: "Optional input text to pass to the shortcut",
        },
      },
      required: ["name"],
    },
  },
  {
    name: "macos_list_shortcuts",
    description: "List all available Shortcuts.app shortcuts",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
  {
    name: "macos_screen_info",
    description: "Get information about connected displays (resolution, scale)",
    inputSchema: {
      type: "object" as const,
      properties: {},
    },
  },
];
