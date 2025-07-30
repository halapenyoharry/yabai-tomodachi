#!/usr/bin/env node

const { execSync, exec } = require('child_process');
const readline = require('readline');

class YabaiTomadachi {
  constructor() {
    this.yabaiPath = '/opt/homebrew/bin/yabai';
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
  }

  runYabaiCommand(command) {
    try {
      const result = execSync(`${this.yabaiPath} ${command}`, { encoding: 'utf8' });
      return result.trim();
    } catch (error) {
      console.error(`Error running yabai command: ${error.message}`);
      return null;
    }
  }

  getWindowInfo() {
    const windows = this.runYabaiCommand('-m query --windows');
    return windows ? JSON.parse(windows) : [];
  }

  getSpaceInfo() {
    const spaces = this.runYabaiCommand('-m query --spaces');
    return spaces ? JSON.parse(spaces) : [];
  }

  focusWindow(direction) {
    this.runYabaiCommand(`-m window --focus ${direction}`);
  }

  moveWindow(direction) {
    this.runYabaiCommand(`-m window --swap ${direction}`);
  }

  resizeWindow(direction, amount = 50) {
    const resizeMap = {
      'left': `left:-${amount}:0`,
      'right': `right:${amount}:0`,
      'up': `top:0:-${amount}`,
      'down': `bottom:0:${amount}`
    };
    this.runYabaiCommand(`-m window --resize ${resizeMap[direction]}`);
  }

  toggleFloat() {
    this.runYabaiCommand('-m window --toggle float');
  }

  toggleFullscreen() {
    this.runYabaiCommand('-m window --toggle zoom-fullscreen');
  }

  showHelp() {
    console.log(`
🌸 Yabai Tomadachi - Your Window Management Friend! 🌸

Commands:
  ?/help     - Show this help
  w          - Show window info
  s          - Show space info
  
  Focus:
  ←/h        - Focus left window
  →/l        - Focus right window  
  ↑/k        - Focus window above
  ↓/j        - Focus window below
  
  Move:
  H          - Swap with left window
  L          - Swap with right window
  K          - Swap with window above
  J          - Swap with window below
  
  Resize:
  <          - Resize smaller (left/up)
  >          - Resize larger (right/down)
  
  Toggle:
  f          - Toggle float
  F          - Toggle fullscreen
  
  q          - Quit
`);
  }

  start() {
    console.log('🌸 Welcome to Yabai Tomadachi! 🌸');
    console.log('Type "?" for help\n');

    this.rl.on('line', (input) => {
      switch(input.trim()) {
        case 'help':
        case '?':
          this.showHelp();
          break;
        
        case 'w':
          const windows = this.getWindowInfo();
          console.log('Windows:', JSON.stringify(windows, null, 2));
          break;
          
        case 's':
          const spaces = this.getSpaceInfo();
          console.log('Spaces:', JSON.stringify(spaces, null, 2));
          break;
          
        // Focus commands
        case 'h':
        case '←':
          this.focusWindow('west');
          console.log('Focused left');
          break;
          
        case 'l':
        case '→':
          this.focusWindow('east');
          console.log('Focused right');
          break;
          
        case 'k':
        case '↑':
          this.focusWindow('north');
          console.log('Focused up');
          break;
          
        case 'j':
        case '↓':
          this.focusWindow('south');
          console.log('Focused down');
          break;
          
        // Move commands
        case 'H':
          this.moveWindow('west');
          console.log('Swapped left');
          break;
          
        case 'L':
          this.moveWindow('east');
          console.log('Swapped right');
          break;
          
        case 'K':
          this.moveWindow('north');
          console.log('Swapped up');
          break;
          
        case 'J':
          this.moveWindow('south');
          console.log('Swapped down');
          break;
          
        // Resize commands
        case '<':
          this.resizeWindow('left');
          console.log('Resized smaller');
          break;
          
        case '>':
          this.resizeWindow('right');
          console.log('Resized larger');
          break;
          
        // Toggle commands
        case 'f':
          this.toggleFloat();
          console.log('Toggled float');
          break;
          
        case 'F':
          this.toggleFullscreen();
          console.log('Toggled fullscreen');
          break;
          
        case 'q':
          console.log('👋 Sayonara!');
          process.exit(0);
          
        default:
          console.log('Unknown command. Type "h" for help.');
      }
      
      this.rl.prompt();
    });

    this.rl.prompt();
  }
}

// Check if yabai is running
try {
  execSync('pgrep yabai', { encoding: 'utf8' });
} catch (error) {
  console.error('⚠️  Yabai is not running! Please start yabai first.');
  process.exit(1);
}

const tomadachi = new YabaiTomadachi();
tomadachi.start();