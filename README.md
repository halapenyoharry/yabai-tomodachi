# fix-yabai-tomadachi

## Journey Overview
- **Started**: 2025-07-30T16:02:54Z
- **Type**: code-archaeology
- **Primary Goal**: Find and restore the working version of yabai-tomadachi that Harry loved

## Current Status
- **Iteration**: 1 (Initial Setup)
- **Approach**: code-archaeology
- **Stage**: Implementation Complete
- **Result**: Successfully recreated yabai-tomadachi with both CLI and GUI versions

## Development Patterns
This project uses songline journey tracking to maintain context across iterate-trash-iterate cycles.

### Key Files
- `songline.json` - Machine-readable journey tracking
- `README.md` - Human-readable project overview
- `.claude/` - Claude Code specific configurations and memories

### Testing Strategy
- **UI Testing**: Screenshot validation + manual verification
- **Functional Testing**: Manual testing of core features
- **Integration Testing**: Local testing with real services

### Iteration Philosophy
Each iteration is self-contained but learns from previous attempts. When we "trash" an approach, we preserve:
- Core insights about the problem space
- Working code patterns that solved sub-problems  
- Tool combinations that worked well
- User experience discoveries

## Usage with Claude Code
```bash
# Start development
cc "Continue working on fix-yabai-tomadachi, review the songline for context"

# Test current iteration  
cc "Test the current build and take screenshots for verification"

# Iterate on specific feature
cc "Improve the [feature] based on testing results"

# Major pivot
cc "The current approach isn't working, archive this iteration and try [new-approach]"
```

The songline.json will automatically track decisions, breakthroughs, and pattern evolution across all iterations.
