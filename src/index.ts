#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { execAsync } from "./utils.js";

const server = new Server(
  {
    name: "yabai-mcp",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

interface YabaiSpace {
  index: number;
  id: number;
  uuid: string;
  type: string;
  visible: number;
  focused: number;
  label?: string;
}

interface YabaiWindow {
  id: number;
  pid: number;
  app: string;
  title: string;
  space: number;
  display: number;
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  focused: number;
  visible: number;
  split: string;
  floating: number;
  sticky: number;
  minimized: number;
}

interface YabaiDisplay {
  id: number;
  uuid: string;
  index: number;
  spaces: number[];
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
}

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "yabai_query_spaces",
        description: "Query information about all spaces",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "yabai_query_windows",
        description: "Query information about windows",
        inputSchema: {
          type: "object",
          properties: {
            space: {
              type: "number",
              description: "Filter windows by space index (optional)",
            },
            display: {
              type: "number",
              description: "Filter windows by display index (optional)",
            },
            app: {
              type: "string",
              description: "Filter windows by app name (optional)",
            },
          },
        },
      },
      {
        name: "yabai_query_displays",
        description: "Query information about all displays",
        inputSchema: {
          type: "object",
          properties: {},
        },
      },
      {
        name: "yabai_focus_space",
        description: "Focus a specific space",
        inputSchema: {
          type: "object",
          properties: {
            space: {
              type: "number",
              description: "Space index to focus",
            },
          },
          required: ["space"],
        },
      },
      {
        name: "yabai_focus_window",
        description: "Focus a window by direction or window ID",
        inputSchema: {
          type: "object",
          properties: {
            direction: {
              type: "string",
              enum: ["north", "south", "east", "west", "next", "prev"],
              description: "Direction to focus (optional)",
            },
            window_id: {
              type: "number",
              description: "Window ID to focus (optional)",
            },
          },
        },
      },
      {
        name: "yabai_move_window",
        description: "Move current window to a space or swap with another window",
        inputSchema: {
          type: "object",
          properties: {
            space: {
              type: "number",
              description: "Space index to move window to (optional)",
            },
            direction: {
              type: "string",
              enum: ["north", "south", "east", "west"],
              description: "Direction to swap window (optional)",
            },
          },
        },
      },
      {
        name: "yabai_resize_window",
        description: "Resize the current window",
        inputSchema: {
          type: "object",
          properties: {
            direction: {
              type: "string",
              enum: ["left", "bottom", "top", "right"],
              description: "Edge to resize",
            },
            pixels: {
              type: "number",
              description: "Number of pixels to resize (positive to grow, negative to shrink)",
            },
          },
          required: ["direction", "pixels"],
        },
      },
      {
        name: "yabai_toggle_window",
        description: "Toggle window properties",
        inputSchema: {
          type: "object",
          properties: {
            property: {
              type: "string",
              enum: ["float", "sticky", "topmost", "split", "zoom-fullscreen", "zoom-parent"],
              description: "Property to toggle",
            },
          },
          required: ["property"],
        },
      },
      {
        name: "yabai_create_space",
        description: "Create a new space",
        inputSchema: {
          type: "object",
          properties: {
            display: {
              type: "number",
              description: "Display index to create space on (optional, defaults to current)",
            },
          },
        },
      },
      {
        name: "yabai_destroy_space",
        description: "Destroy a space",
        inputSchema: {
          type: "object",
          properties: {
            space: {
              type: "number",
              description: "Space index to destroy",
            },
          },
          required: ["space"],
        },
      },
      {
        name: "yabai_label_space",
        description: "Set a label for a space",
        inputSchema: {
          type: "object",
          properties: {
            space: {
              type: "number",
              description: "Space index to label",
            },
            label: {
              type: "string",
              description: "Label to set for the space",
            },
          },
          required: ["space", "label"],
        },
      },
      {
        name: "yabai_set_layout",
        description: "Set the layout for current or specified space",
        inputSchema: {
          type: "object",
          properties: {
            layout: {
              type: "string",
              enum: ["bsp", "float", "stack"],
              description: "Layout type to set",
            },
            space: {
              type: "number",
              description: "Space index to set layout for (optional, defaults to current)",
            },
          },
          required: ["layout"],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args = {} } = request.params;

  try {
    switch (name) {
      case "yabai_query_spaces": {
        const output = await execAsync("yabai -m query --spaces");
        const spaces: YabaiSpace[] = JSON.parse(output);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(spaces, null, 2),
            },
          ],
        };
      }

      case "yabai_query_windows": {
        let command = "yabai -m query --windows";
        const windows: YabaiWindow[] = JSON.parse(await execAsync(command));
        
        let filtered = windows;
        if ('space' in args && args.space !== undefined) {
          filtered = filtered.filter(w => w.space === args.space as number);
        }
        if ('display' in args && args.display !== undefined) {
          filtered = filtered.filter(w => w.display === args.display as number);
        }
        if ('app' in args && args.app !== undefined) {
          const appFilter = String(args.app);
          filtered = filtered.filter(w => 
            w.app.toLowerCase().includes(appFilter.toLowerCase())
          );
        }
        
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(filtered, null, 2),
            },
          ],
        };
      }

      case "yabai_query_displays": {
        const output = await execAsync("yabai -m query --displays");
        const displays: YabaiDisplay[] = JSON.parse(output);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(displays, null, 2),
            },
          ],
        };
      }

      case "yabai_focus_space": {
        await execAsync(`yabai -m space --focus ${args.space as number}`);
        return {
          content: [
            {
              type: "text",
              text: `Focused space ${args.space}`,
            },
          ],
        };
      }

      case "yabai_focus_window": {
        if ('window_id' in args && args.window_id) {
          await execAsync(`yabai -m window --focus ${args.window_id as number}`);
          return {
            content: [
              {
                type: "text",
                text: `Focused window ${args.window_id}`,
              },
            ],
          };
        } else if ('direction' in args && args.direction) {
          await execAsync(`yabai -m window --focus ${args.direction as string}`);
          return {
            content: [
              {
                type: "text",
                text: `Focused window to the ${args.direction}`,
              },
            ],
          };
        } else {
          throw new Error("Either window_id or direction must be specified");
        }
      }

      case "yabai_move_window": {
        if ('space' in args && args.space !== undefined) {
          await execAsync(`yabai -m window --space ${args.space as number}`);
          return {
            content: [
              {
                type: "text",
                text: `Moved window to space ${args.space}`,
              },
            ],
          };
        } else if ('direction' in args && args.direction) {
          await execAsync(`yabai -m window --swap ${args.direction as string}`);
          return {
            content: [
              {
                type: "text",
                text: `Swapped window with ${args.direction} window`,
              },
            ],
          };
        } else {
          throw new Error("Either space or direction must be specified");
        }
      }

      case "yabai_resize_window": {
        await execAsync(`yabai -m window --resize ${args.direction as string}:${args.pixels as number}:0`);
        return {
          content: [
            {
              type: "text",
              text: `Resized window ${args.direction} by ${args.pixels} pixels`,
            },
          ],
        };
      }

      case "yabai_toggle_window": {
        await execAsync(`yabai -m window --toggle ${args.property as string}`);
        return {
          content: [
            {
              type: "text",
              text: `Toggled window property: ${args.property}`,
            },
          ],
        };
      }

      case "yabai_create_space": {
        const command = 'display' in args && args.display 
          ? `yabai -m display ${args.display as number} --space mouse`
          : "yabai -m space --create";
        await execAsync(command);
        return {
          content: [
            {
              type: "text",
              text: 'display' in args && args.display 
                ? `Created space on display ${args.display}`
                : "Created new space on current display",
            },
          ],
        };
      }

      case "yabai_destroy_space": {
        await execAsync(`yabai -m space ${args.space as number} --destroy`);
        return {
          content: [
            {
              type: "text",
              text: `Destroyed space ${args.space}`,
            },
          ],
        };
      }

      case "yabai_label_space": {
        await execAsync(`yabai -m space ${args.space as number} --label "${args.label as string}"`);
        return {
          content: [
            {
              type: "text",
              text: `Labeled space ${args.space} as "${args.label}"`,
            },
          ],
        };
      }

      case "yabai_set_layout": {
        const command = 'space' in args && args.space 
          ? `yabai -m space ${args.space as number} --layout ${args.layout as string}`
          : `yabai -m space --layout ${args.layout as string}`;
        await execAsync(command);
        return {
          content: [
            {
              type: "text",
              text: 'space' in args && args.space 
                ? `Set layout of space ${args.space} to ${args.layout}`
                : `Set layout of current space to ${args.layout}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
      isError: true,
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Yabai MCP server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});