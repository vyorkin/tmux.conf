# tmux.conf

My tmux config with automatic dark/light theme switching, vim-style navigation, session persistence, and a curated plugin set.

## Overview

The configuration is split across several files:

```
tmux.conf                 # Main config — prefix, bindings, plugin settings
tmux/
  themes/
    inspired_github.tmux.conf       # Light theme (used with macOS light mode)
    tomorrow_night.tmux.conf        # Dark theme (used with macOS dark mode)
    tomorrow_light.tmux.conf        # Alternative light theme
    tomorrow_night_bright.tmux.conf # Brighter dark variant
  plugins/
    tpm/          # Tmux Plugin Manager (git submodule)
    ...           # Remaining plugins installed by TPM at runtime
```

`tmux.conf` is the entry point. It sources a theme file chosen automatically by `tmux-dark-notify` based on the current macOS appearance, and loads all plugins via TPM at the end.

## How it works

### Prefix

The prefix is `Ctrl+Space` (instead of the default `Ctrl+B`). Pressing `Space` alone after the prefix forwards the prefix to nested tmux sessions.

### Key bindings

| Key | Action |
|---|---|
| `prefix + j` | Split vertically (panes side by side) |
| `prefix + l` | Split horizontally (panes stacked) |
| `prefix + q` | Kill window |
| `prefix + x` | Kill pane |
| `prefix + C-h` | Toggle pane zoom |
| `prefix + J/K/H/L` | Resize panes |
| `prefix + =` | Tiled layout |
| `prefix + o` | Main-vertical layout |
| `prefix + \|` | Even-horizontal layout |
| `prefix + r` | Rotate window |
| `prefix + e` | Toggle pane synchronization |
| `prefix + Tab` | Last window |
| `prefix + /` | Copy mode + incremental search |
| `prefix + C-Space` | Enter copy mode |
| `prefix + p` | Paste buffer |
| `prefix + G` | Open lazygit |
| `Alt + p / n` | Previous / next window |
| `Alt + t` | Popup scratch terminal (80% size) |
| `Ctrl + h/j/k/l` | Navigate panes (works across vim splits via vim-tmux-navigator) |

Copy mode uses vi keys: `v` to select, `V` for rectangle toggle, `Escape` to cancel.

### Dark / light theme switching

The `tmux-dark-notify` plugin watches macOS appearance changes (via `dark-notify`) and automatically sources the matching theme file:

- **Light mode** &rarr; `tmux/themes/inspired_github.tmux.conf`
- **Dark mode** &rarr; `tmux/themes/tomorrow_night.tmux.conf`

The runtime theme state is written to `~/.local/state/tmux/tmux-dark-notify-theme.conf` and sourced on tmux start.

### Session persistence

`tmux-resurrect` + `tmux-continuum` save and restore sessions automatically:

- Sessions are saved every 15 minutes
- Pane contents are preserved
- Neovim sessions are restored using `:mksession`
- Auto-restore is enabled on tmux server start

### Defaults

- 100,000 line scrollback
- Base index 1 for windows and panes
- Mouse enabled
- Status bar at the top
- Windows renumber on close
- 256-color + true RGB

## Plugins

| Plugin | What it does |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard integration |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless `C-h/j/k/l` navigation between vim and tmux |
| [tmux-menus](https://github.com/jaclu/tmux-menus) | Context menus |
| [extrakto](https://github.com/laktak/extrakto) | Fuzzy text extraction from panes |
| [tmux-neolazygit](https://github.com/AngryMorrocoy/tmux-neolazygit) | Lazygit popup |
| [tmux-mighty-scroll](https://github.com/noscript/tmux-mighty-scroll) | Line-by-line scrolling for man, less, fzf, node, claude |
| [tmux-dark-notify](https://github.com/erikw/tmux-dark-notify) | Auto dark/light theme switching |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Session save/restore |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Automatic periodic saving + auto-restore |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Session picker (`prefix + C-a`) |

## Requirements

```
brew install dark-notify
```

## Setup

1. Clone this repo with submodules:

   ```sh
   git clone https://github.com/vyorkin/tmux.conf.git --recurse-submodules --depth 1
   ```

2. Symlink `tmux.conf` to `~/.tmux.conf`:

   ```sh
   ln -sf $(pwd)/tmux.conf ~/.tmux.conf
   ```

3. Symlink [tmux plugin manager](https://github.com/tmux-plugins/tpm):

   ```sh
   mkdir -p ~/.tmux/plugins
   ln -sf $(pwd)/tmux/plugins/tpm ~/.tmux/plugins/tpm
   ```

4. Install plugins:

   ```sh
   ~/.tmux/plugins/tpm/bin/install_plugins
   ```

TPM is also auto-installed on first tmux start if not already present.
