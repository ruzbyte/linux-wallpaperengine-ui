# Linux Wallpaper Engine UI

https://github.com/user-attachments/assets/c150bf0b-b6ec-4074-bb94-957703445baf

A Flutter-based graphical user interface for the linux-wallpaperengine utility. This application allows you to browse your subscribed Steam Workshop wallpapers and configure them for multiple monitors on Linux.

## Features

- **Workshop Browser**: View and select wallpapers from your local Steam Workshop directory.
- **Multi-Monitor Support**: Configure different wallpapers and scaling options for each connected monitor.
- **Global Settings**: Control application-wide settings such as FPS limit, Silent Mode (audio mute), and Parallax effects.
- **Persistence**: Automatically saves your configuration and window settings to `~/.config/wpeui/config.json`.
- **Search**: Faster browsing :D

## Prerequisites

1. **linux-wallpaperengine**: This application acts as a frontend. You must have the backend utility installed and accessible in your system PATH.

   - Repository: https://github.com/Almamu/linux-wallpaperengine

2. **Steam Workshop Content**: You need to have Wallpaper Engine wallpapers downloaded via Steam. The application looks for content in the default Steam Workshop directory for App ID 431960.

## Installation and Running

### Release

Download the current release. Put it where you like it, add it to the PATH and execute it via the Terminal. A desktop entry is comming next.

### Manually

1. Clone the repository.
2. Ensure you have Flutter installed and configured for Linux desktop development.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run -d linux
   ```

## Configuration

The application currently looks for Workshop items in a specific directory. If your Steam library is in a non-standard location, you may need to modify the path in `lib/main.dart`.

Configuration files are stored in:
`~/.config/wpeui/config.json`

## Usage

### GUI

1. **Browse**: Navigate to the "Browse" tab to see your available wallpapers.
2. **Select**: Click on a wallpaper to view details.
3. **Configure**: Select a monitor and scaling mode, then click "Set for Monitor".
4. **Apply**: Go to the "Monitors" tab to review your setup. Adjust global settings (FPS, etc.) and click "Apply All" to launch the wallpaper engine.
5. **Search**: Search by Name or Tags to browse faster.

### CLI

For automatic startup of your configuration for Window Managers like Niri or Hyprland some CLI Options are available, use `--no-gui` for skipping the GUI.

```sh
exec-once = wpeui --no-gui --apply # For hyprland
spawn-sh-at-startup = "wpeui --no-gui --apply" # For niri
```

## Special Thanks to

- [Almamu](https://github.com/Almamu) creator of the actual wallpaperengine

Now I finally have my wallpapers on linux :)
