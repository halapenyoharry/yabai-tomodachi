# Hacker News Submission

## Title
Show HN: yabai-tomodachi – AI-powered companion for macOS window management

## Link
https://github.com/halapenyoharry/yabai-tomodachi

## First Comment (post immediately after submission)

I built this to solve my own frustrations with window management on macOS. While Yabai is incredibly powerful, I found myself:

1. Constantly restarting it when windows got "stuck"
2. Forgetting the exact syntax for commands
3. Wishing I could use natural language instead of memorizing shortcuts

yabai-tomodachi adds a friendly menu bar interface and Claude AI integration via MCP (Model Context Protocol). You can now say things like "set up my coding workspace" or "move all browsers to the second monitor" instead of chaining multiple commands.

Technical details:
- Menu bar app: Native Swift using NSStatusItem
- MCP server: TypeScript, provides 12 tools for window/space control
- Distribution: Signed .pkg installer with LaunchAgent support
- AI integration: Works with Claude Desktop via stdio transport

The interesting part is the MCP integration. MCP is designed for AI assistants to use tools, but I think it has potential as a universal tool protocol. Imagine if all your CLI tools had MCP servers - any app could discover and use them, not just AI assistants.

This is my first Swift app and first time creating a macOS installer, so I'd love feedback on the implementation. The code is MIT licensed and PRs are welcome!

What window management workflows would you want AI to help with?