# AeroSpace Config

A native macOS editor for [AeroSpace](https://github.com/nikitabobko/AeroSpace)
tiling-window-manager configurations.

AeroSpace Config wraps a local WKWebView interface in a small Swift app. It
gives you a visual editor for common AeroSpace settings while keeping the raw
TOML available for anything the GUI does not cover.

## Features

- Edit shortcuts for Main and Service modes
- Filter shortcuts and add or remove bindings
- Edit persistent workspace names
- Edit workspace-to-monitor assignments
- Review existing `[[on-window-detected]]` window rules
- Adjust layout, orientation, startup, focus-follows-mouse and gap settings
- Edit the complete TOML file directly
- Open a config with the native macOS file picker or by entering a path
- Save changes back to the selected file
- Ask AeroSpace to reload after saving
- No account, network service or embedded personal configuration

## Screens included

The app has six main views:

1. **Overview** — summary metrics, workspace preview and shortcut highlights
2. **Shortcuts** — Main and Service mode keybinding editor
3. **Workspaces** — persistent workspaces and monitor assignments
4. **Window rules** — read-only summary of `[[on-window-detected]]` rules
5. **Preferences** — layout, gaps and behavior switches
6. **Config file** — raw TOML editor and file picker

## Requirements

- macOS 13 Ventura or later
- Xcode Command Line Tools with the Swift compiler
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) installed

Install Xcode Command Line Tools if needed:

```sh
xcode-select --install
```

## Build

From the repository root:

```sh
chmod +x build.sh
./build.sh
open "build/AeroSpace Config.app"
```

The script creates an unsigned app bundle at:

```text
build/AeroSpace Config.app
```

Because it is locally built and unsigned, macOS may require you to approve it
in System Settings → Privacy & Security the first time you open it.

## Usage

1. Launch the app.
2. It first tries to open `~/.aerospace.toml`.
3. If that file does not exist, use **Browse files…** or enter another path.
4. Make changes in the visual editor or the raw TOML editor.
5. Press **Save changes**.
6. The app writes the file and attempts to run:

   ```sh
   aerospace reload-config
   ```

The app looks for the AeroSpace executable at:

```text
/opt/homebrew/bin/aerospace
/usr/local/bin/aerospace
```

If AeroSpace is installed somewhere else, saving still works but automatic
reload may need to be done manually.

## File layout

```text
aerospace-config/
├── AeroSpaceStudio.swift   Native macOS app, WKWebView host and file bridge
├── index.html              Complete visual editor UI and TOML logic
├── build.sh                Builds the unsigned .app bundle
├── AppIcon.icns             Application icon
├── README.md                This document
├── LICENSE                  MIT license
└── .gitignore               Build output and local config exclusions
```

### Runtime files

The app reads and writes the config file selected by the user, usually:

```text
~/.aerospace.toml
```

No config contents, usernames, tokens or paths are built into the repository.

## How it works

- The Swift shell creates a WKWebView and loads `index.html` from the app bundle.
- The page communicates with native code through `window.webkit.messageHandlers.aero`.
- The Swift layer handles:
  - reading the selected TOML file
  - writing saved contents
  - native file selection
  - launching `aerospace reload-config`
- The HTML/JavaScript layer handles:
  - parsing the TOML
  - rendering the editor views
  - collecting changes
  - generating the updated TOML text

The app is intentionally local-only. It does not make network requests.

## Privacy

- There is no telemetry, analytics or account system.
- The repository contains no personal config data.
- The app can read and write any TOML file you explicitly choose.
- `.aerospace.toml` and generated app bundles are ignored by Git.

## Troubleshooting

### The app opens but shows “Config file not found”

Create `~/.aerospace.toml`, or open an existing AeroSpace config through
**Config file → Browse files…**.

### Save succeeds but AeroSpace does not reload

Check that `aerospace` is installed at one of the two expected Homebrew paths.
You can also reload manually:

```sh
aerospace reload-config
```

### The app cannot be opened

The build is unsigned. Open System Settings → Privacy & Security and approve
the app, or build and run it locally from source.

### Changes look wrong in the raw editor

Use **Revert** before saving, or close and reopen the app. The app does not
modify the on-disk file until **Save changes** is pressed.

## Development

The UI is plain HTML/CSS/JavaScript in `index.html`; there is no frontend build
step. Rebuild the app after changing either source file:

```sh
./build.sh
```

## AI disclaimer

This project was developed with AI assistance. Review the code and test it
against your own AeroSpace configuration before relying on it.

## License

MIT. See [LICENSE](LICENSE).
