# AeroSpace Config

A native macOS interface for editing an [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling window manager configuration.

## Features

- Edit shortcut bindings in Main and Service modes
- Configure workspaces, monitor assignments, window rules, and layout preferences
- Edit the TOML file directly
- Choose a config file with the native file picker or enter its path
- Save changes to the selected file and ask AeroSpace to reload its config

The default config is resolved from the current macOS user's home folder as `~/.aerospace.toml`. No username or config contents are embedded in the project.

## Build

Requires macOS 13 or later and Xcode Command Line Tools (Swift compiler).

```sh
./build.sh
open "build/AeroSpace Config.app"
```

The build script creates an unsigned app at `build/AeroSpace Config.app`. macOS may ask you to approve opening an app built locally.
