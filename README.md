# tmux.conf

My tmux config with automatic theme switching, vim-style navigation, session persistence, and a curated plugin set.

Theme switching works two ways, automatically detected:

- **macOS** — [`tmux-dark-notify`](https://github.com/erikw/tmux-dark-notify) follows the system light/dark appearance.
- **Linux (Omarchy)** — a `theme-set` hook regenerates the tmux palette from the active Omarchy theme.

## Overview

The configuration is split across several files:

```
tmux.conf                 # Main config — prefix, bindings, plugin settings
omarchy/
  tmux-theme.sh           # Omarchy (Linux) theme hook — regenerates the tmux palette
workmux/
  config.yaml             # Global workmux config (~/.config/workmux/config.yaml)
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

`tmux.conf` is the entry point. At the end it sources a theme (the Omarchy-generated palette when running on Linux/Omarchy, otherwise the `tmux-dark-notify` theme on macOS), then loads all plugins via TPM. The theme comes first so it doesn't overwrite the auto-save hook that `tmux-continuum` adds to `status-right`.

## How it works

### Prefix

The prefix is `Ctrl+Space` (instead of the default `Ctrl+B`). Pressing `Space` alone after the prefix forwards the prefix to nested tmux sessions.

### Key bindings

| Key | Action |
|---|---|
| `prefix + j` | Split vertically (panes side by side), in the current directory |
| `prefix + l` | Split horizontally (panes stacked), in the current directory |
| `prefix + c` | New window in the current directory |
| `prefix + q` | Kill window (asks for confirmation) |
| `prefix + R` | Reload config |
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
| `Alt + t` | Toggle floating scratch terminal (floax) |
| `prefix + P` | Floax menu (resize, embed into the window, ...) |
| `prefix + a` | workmux: jump to the agent that finished or waits for input |
| `prefix + W` | workmux dashboard |
| `Ctrl + h/j/k/l` | Navigate panes (works across vim splits via vim-tmux-navigator) |

Copy mode uses vi keys: `v` to select, `V` for rectangle toggle, `Escape` to cancel.

### Theme switching

#### macOS — `tmux-dark-notify`

The `tmux-dark-notify` plugin watches macOS appearance changes (via `dark-notify`) and automatically sources the matching theme file:

- **Light mode** &rarr; `tmux/themes/inspired_github.tmux.conf`
- **Dark mode** &rarr; `tmux/themes/tomorrow_night.tmux.conf`

The runtime theme state is written to `~/.local/state/tmux/tmux-dark-notify-theme.conf` and sourced on tmux start.

#### Linux (Omarchy) — native theme hook

On Omarchy, tmux follows the active Omarchy theme instead. `omarchy/tmux-theme.sh` is installed as an Omarchy `theme-set` / `post-boot` hook. For every theme change it:

1. resolves semantic colors from `~/.local/state/omarchy/current/theme/colors.toml` through `omarchy-theme-color` (the same parser the rest of the desktop uses),
2. writes `~/.local/state/tmux/omarchy-theme.conf`, and
3. sources it into the running tmux server, so the change is instant.

The generated `status-right` keeps `tmux-continuum`'s auto-save hook, so switching themes doesn't stop session auto-saving.

`tmux.conf` sources that generated file on startup, and prefers it over `tmux-dark-notify`; the `tmux-dark-notify` path is only used when the Omarchy hook is not installed.

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
- Closing the last window of a session switches to another session instead of exiting
- 256-color + true RGB
- Extended keys (Shift+Enter, Ctrl+Enter, ...) passed through to apps
- Passthrough enabled for the kitty graphics protocol (images in nvim, yazi)
- OSC 52 clipboard (works over SSH)

### Parallel agents — workmux

[workmux](https://github.com/raine/workmux) creates a git worktree plus a tmux
session per task, with Claude running in it (`workmux add <name>`,
`workmux merge`, `workmux remove`). `workmux/config.yaml` sets session mode, so
every worktree is a regular session in sessionx.

Agent status icons (🤖 working, 💬 waiting, ✅ done) are rendered by the window
formats from `omarchy/tmux-theme.sh` via `#{@workmux_status}`, so workmux's own
format patching is disabled (`status_format: false`) and the icons keep the
theme colors after `omarchy theme set`.

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
| [tmux-dark-notify](https://github.com/erikw/tmux-dark-notify) | Auto dark/light theme switching (macOS only, not loaded on Linux) |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Session save/restore |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Automatic periodic saving + auto-restore |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Session picker (`prefix + C-a`); unmatched queries open a session from zoxide |
| [tmux-floax](https://github.com/omerxx/tmux-floax) | Floating scratch terminal (`Alt + t`) |

## Requirements

- **macOS**: `brew install dark-notify`
- **Omarchy (Linux)**: nothing extra — the hook uses the bundled `omarchy-theme-color`.
- **Optional**: [zoxide](https://github.com/ajeetdsouza/zoxide) for sessionx, [workmux](https://github.com/raine/workmux) for parallel agents.

## Setup

1. Clone this repo with submodules:

   ```sh
   git clone https://github.com/vyorkin/tmux.conf.git --recurse-submodules --depth 1
   ```

2. Symlink the config into the location tmux actually reads:

   **macOS** — to `~/.tmux.conf`:

   ```sh
   ln -sf $(pwd)/tmux.conf ~/.tmux.conf
   ```

   **Omarchy (Linux)** — to the XDG path `~/.config/tmux/tmux.conf`. tmux loads
   `/etc/tmux.conf`, then `~/.tmux.conf`, then the XDG file, so Omarchy's stock
   `~/.config/tmux/tmux.conf` would otherwise override this config. Put this
   config there instead and remove `~/.tmux.conf` so it loads exactly once:

   ```sh
   ln -sf $(pwd)/tmux.conf ~/.config/tmux/tmux.conf
   rm -f ~/.tmux.conf
   ```

   The stock file also lives in `/usr/share/omarchy/config/tmux/tmux.conf` if you
   ever need it back.

3. Symlink [tmux plugin manager](https://github.com/tmux-plugins/tpm):

   ```sh
   mkdir -p ~/.tmux/plugins
   ln -sf $(pwd)/tmux/plugins/tpm ~/.tmux/plugins/tpm
   ```

4. Install plugins:

   ```sh
   ~/.tmux/plugins/tpm/bin/install_plugins
   ```

   TPM installs plugins under `$XDG_CONFIG_HOME/tmux/plugins` (`~/.config/tmux/plugins`).

5. **(Omarchy only)** install the theme hooks so tmux follows the active theme:

   ```sh
   mkdir -p ~/.config/omarchy/hooks/theme-set.d ~/.config/omarchy/hooks/post-boot.d
   ln -sf $(pwd)/omarchy/tmux-theme.sh ~/.config/omarchy/hooks/theme-set.d/tmux
   ln -sf $(pwd)/omarchy/tmux-theme.sh ~/.config/omarchy/hooks/post-boot.d/tmux
   ```

   Then run it once to generate the initial palette (or just open tmux):

   ```sh
   ~/.config/omarchy/hooks/theme-set.d/tmux
   ```

6. **(Optional)** set up workmux:

   ```sh
   mise use -g github:raine/workmux
   mkdir -p ~/.config/workmux
   ln -sf $(pwd)/workmux/config.yaml ~/.config/workmux/config.yaml
   # Status tracking hooks for Claude Code
   claude plugin marketplace add raine/workmux
   claude plugin install workmux-status
   ```

> **Note:** `omarchy refresh tmux` restores the stock config and will replace the
> `~/.config/tmux/tmux.conf` symlink. Re-run step 2 if that happens.

TPM is also auto-installed on first tmux start if not already present.
