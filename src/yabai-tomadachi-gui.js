#!/usr/bin/env node

const { app, Menu, Tray, globalShortcut, dialog } = require('electron');
const { execSync } = require('child_process');
const path = require('path');

class YabaiTomadachiGUI {
  constructor() {
    this.yabaiPath = '/opt/homebrew/bin/yabai';
    this.tray = null;
    this.presets = {
      'Focus Mode': {
        description: 'Single window, no distractions',
        commands: [
          '-m space --layout float',
          '-m window --toggle zoom-fullscreen'
        ]
      },
      'Split View': {
        description: 'Two windows side by side',
        commands: [
          '-m space --layout bsp',
          '-m space --balance'
        ]
      },
      'Grid Layout': {
        description: 'Organize windows in a grid',
        commands: [
          '-m space --layout bsp',
          '-m config window_gap 10',
          '-m space --balance'
        ]
      }
    };
  }

  runYabaiCommand(command) {
    try {
      const result = execSync(`${this.yabaiPath} ${command}`, { encoding: 'utf8' });
      return result.trim();
    } catch (error) {
      console.error(`Error: ${error.message}`);
      return null;
    }
  }

  createTrayMenu() {
    const contextMenu = Menu.buildFromTemplate([
      {
        label: '🌸 Yabai Tomadachi',
        enabled: false
      },
      { type: 'separator' },
      {
        label: 'Window Controls',
        submenu: [
          {
            label: 'Focus Left',
            accelerator: 'Alt+H',
            click: () => this.runYabaiCommand('-m window --focus west')
          },
          {
            label: 'Focus Right',
            accelerator: 'Alt+L',
            click: () => this.runYabaiCommand('-m window --focus east')
          },
          {
            label: 'Focus Up',
            accelerator: 'Alt+K',
            click: () => this.runYabaiCommand('-m window --focus north')
          },
          {
            label: 'Focus Down',
            accelerator: 'Alt+J',
            click: () => this.runYabaiCommand('-m window --focus south')
          }
        ]
      },
      {
        label: 'Layout Presets',
        submenu: Object.entries(this.presets).map(([name, preset]) => ({
          label: name,
          toolTip: preset.description,
          click: () => this.applyPreset(preset)
        }))
      },
      {
        label: 'Quick Actions',
        submenu: [
          {
            label: 'Toggle Float',
            accelerator: 'Alt+F',
            click: () => this.runYabaiCommand('-m window --toggle float')
          },
          {
            label: 'Toggle Fullscreen',
            accelerator: 'Alt+Shift+F',
            click: () => this.runYabaiCommand('-m window --toggle zoom-fullscreen')
          },
          {
            label: 'Balance Windows',
            click: () => this.runYabaiCommand('-m space --balance')
          },
          {
            label: 'Rotate Tree',
            click: () => this.runYabaiCommand('-m space --rotate 90')
          }
        ]
      },
      { type: 'separator' },
      {
        label: 'Spaces',
        submenu: [
          {
            label: 'Create Space',
            click: () => this.runYabaiCommand('-m space --create')
          },
          {
            label: 'Destroy Space',
            click: () => this.runYabaiCommand('-m space --destroy')
          },
          {
            label: 'Focus Next Space',
            accelerator: 'Alt+Right',
            click: () => this.runYabaiCommand('-m space --focus next')
          },
          {
            label: 'Focus Previous Space',
            accelerator: 'Alt+Left',
            click: () => this.runYabaiCommand('-m space --focus prev')
          }
        ]
      },
      { type: 'separator' },
      {
        label: 'Settings',
        submenu: [
          {
            label: 'Window Gap',
            submenu: [
              { label: 'None', click: () => this.runYabaiCommand('-m config window_gap 0') },
              { label: 'Small (5px)', click: () => this.runYabaiCommand('-m config window_gap 5') },
              { label: 'Medium (10px)', click: () => this.runYabaiCommand('-m config window_gap 10') },
              { label: 'Large (20px)', click: () => this.runYabaiCommand('-m config window_gap 20') }
            ]
          },
          {
            label: 'Padding',
            submenu: [
              { label: 'None', click: () => this.runYabaiCommand('-m config top_padding 0 && -m config bottom_padding 0 && -m config left_padding 0 && -m config right_padding 0') },
              { label: 'Small', click: () => this.runYabaiCommand('-m config top_padding 5 && -m config bottom_padding 5 && -m config left_padding 5 && -m config right_padding 5') },
              { label: 'Medium', click: () => this.runYabaiCommand('-m config top_padding 10 && -m config bottom_padding 10 && -m config left_padding 10 && -m config right_padding 10') }
            ]
          }
        ]
      },
      { type: 'separator' },
      {
        label: 'About',
        click: () => {
          dialog.showMessageBox({
            type: 'info',
            title: 'Yabai Tomadachi',
            message: 'Yabai Tomadachi v1.0',
            detail: 'Your friendly window management companion!\n\nMade with ❤️ for Harry',
            buttons: ['OK']
          });
        }
      },
      {
        label: 'Quit',
        accelerator: 'Cmd+Q',
        click: () => {
          app.quit();
        }
      }
    ]);

    this.tray.setContextMenu(contextMenu);
  }

  applyPreset(preset) {
    preset.commands.forEach(cmd => this.runYabaiCommand(cmd));
  }

  registerGlobalShortcuts() {
    // Window focus shortcuts
    globalShortcut.register('Alt+H', () => this.runYabaiCommand('-m window --focus west'));
    globalShortcut.register('Alt+L', () => this.runYabaiCommand('-m window --focus east'));
    globalShortcut.register('Alt+K', () => this.runYabaiCommand('-m window --focus north'));
    globalShortcut.register('Alt+J', () => this.runYabaiCommand('-m window --focus south'));
    
    // Window movement shortcuts
    globalShortcut.register('Alt+Shift+H', () => this.runYabaiCommand('-m window --swap west'));
    globalShortcut.register('Alt+Shift+L', () => this.runYabaiCommand('-m window --swap east'));
    globalShortcut.register('Alt+Shift+K', () => this.runYabaiCommand('-m window --swap north'));
    globalShortcut.register('Alt+Shift+J', () => this.runYabaiCommand('-m window --swap south'));
    
    // Toggle shortcuts
    globalShortcut.register('Alt+F', () => this.runYabaiCommand('-m window --toggle float'));
    globalShortcut.register('Alt+Shift+F', () => this.runYabaiCommand('-m window --toggle zoom-fullscreen'));
    
    // Space navigation
    globalShortcut.register('Alt+Left', () => this.runYabaiCommand('-m space --focus prev'));
    globalShortcut.register('Alt+Right', () => this.runYabaiCommand('-m space --focus next'));
  }

  init() {
    // Create tray icon (you'll need to add an icon file)
    this.tray = new Tray(path.join(__dirname, '../assets/icon.png'));
    this.tray.setToolTip('Yabai Tomadachi');
    
    this.createTrayMenu();
    this.registerGlobalShortcuts();
    
    // Check if yabai is running
    try {
      execSync('pgrep yabai', { encoding: 'utf8' });
    } catch (error) {
      dialog.showErrorBox('Yabai Not Running', 'Please start yabai before using Yabai Tomadachi.');
      app.quit();
    }
  }
}

app.whenReady().then(() => {
  const tomadachi = new YabaiTomadachiGUI();
  tomadachi.init();
});

app.on('window-all-closed', (e) => {
  e.preventDefault();
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});