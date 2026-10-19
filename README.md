# tmux.conf

My tmux config with automatic theme switching, vim-style navigation, session persistence, parallel AI agents (workmux), shell-aware copy mode, and a curated plugin set. Targets tmux 3.7+, with extra features that switch on automatically under tmux 3.8.

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
shell/
  osc133.zsh              # zsh prompt marks (OSC 133) for tmux
scripts/
  notify-command-finished.sh  # Desktop notification for long commands (tmux 3.8+)
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
| `prefix + z` | Toggle pane zoom |
| `prefix + J/K/H/L` | Resize panes |
| `prefix + =` | Tiled layout |
| `prefix + o` | Main-vertical layout |
| `prefix + \|` | Even-horizontal layout |
| `prefix + r` | Rotate window |
| `prefix + e` | Toggle pane synchronization |
| `prefix + C-a` | Session picker (sessionx; unmatched queries jump via zoxide) |
| `prefix + Tab` | Fuzzy window switcher (tmux 3.8+); last window on older tmux |
| `prefix + S-Tab` | Fuzzy session switcher (tmux 3.8+) |
| `prefix + u` | extrakto: fuzzy-pick text, URLs, paths from the pane |
| `prefix + /` | Copy mode + incremental search |
| `prefix + C-Space` | Enter copy mode |
| `prefix + p` | Paste buffer |
| `prefix + G` | Open lazygit |
| `Alt + p / n` | Previous / next window |
| `Alt + t` | Toggle floating scratch terminal (floax) |
| `prefix + P` | Floax menu (resize, embed into the window, ...) |
| `prefix + a` | workmux: jump to the agent that finished or waits for input |
| `prefix + W` | workmux dashboard |
| `prefix + C-t` | Toggle workmux agent sidebar |
| `Ctrl + h/j/k/l` | Navigate panes; inside Neovim it walks Neovim's windows first, then tmux panes (smart-splits) |
| `Alt + h/j/k/l` | Resize: Neovim windows inside Neovim, tmux panes elsewhere (smart-splits) |

Copy mode uses vi keys:

| Key | Action |
|---|---|
| `v` | Begin selection |
| `V` | Toggle rectangle selection |
| `[` / `]` | Previous / next shell prompt (needs [OSC 133 marks](#shell-integration-osc-133)) |
| `r` | Refresh content from the pane (tmux 3.8+; copy mode also refreshes automatically) |
| `Escape` | Cancel |

Line numbers in copy mode are vim-style hybrid: absolute for the current line, relative for the others.

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

The generated file styles the status bar, window list, pane borders, scrollbars, messages and copy mode, and also carries:

- `tmux-continuum`'s auto-save hook in `status-right`, so switching themes doesn't stop session auto-saving;
- workmux agent status icons (`#{@workmux_status}`) in the window formats;
- floax border and text colors (both the `@floax-*` options and the `FLOAX_*` environment it reads at runtime).

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

### Shell integration (OSC 133)

`shell/osc133.zsh` marks each prompt, command start, and command end with
OSC 133 escape sequences inside tmux (Starship doesn't emit them). tmux uses the
marks for `[` / `]` prompt jumps in copy mode and, on 3.8+, for the
`pane-command-finished` hook.

### tmux 3.8+

These settings sit in a `%if` version block, so older tmux ignores them:

- `theme terminal`: built-in styles use the terminal palette (the Omarchy colors in kitty) instead of tmux's own light/dark themes
- Auto-hiding pane scrollbars, colored by the Omarchy theme
- Copy mode stays live: new output keeps appearing while you scroll back (it follows only at the bottom and pauses during a selection)
- A desktop notification (`notify-send`) when a command that ran 10s or more finishes in a window you aren't looking at; set `TMUX_NOTIFY_MIN_SECONDS` to change the threshold
- `prefix + Tab` / `prefix + S-Tab` open the built-in fuzzy window / session switcher

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
| [backend-tmux](https://github.com/smart-splits-nvim/backend-tmux) | Seamless `C-h/j/k/l` navigation and `M-h/j/k/l` resizing between Neovim and tmux. The tmux side of smart-splits.nvim v3, which ships no multiplexer support in core |
| [tmux-menus](https://github.com/jaclu/tmux-menus) | Context menus |
| [extrakto](https://github.com/laktak/extrakto) | Fuzzy text extraction from panes (`prefix + u`) |
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
- **tmux 3.7+** (`copy-mode-line-numbers` doesn't exist before 3.7); 3.8 enables the extras listed under [tmux 3.8+](#tmux-38).
- **Optional**:
  - [zoxide](https://github.com/ajeetdsouza/zoxide) for sessionx;
  - [workmux](https://github.com/raine/workmux) for parallel agents, plus a [Nerd Font](https://www.nerdfonts.com/) for its icons (`nerdfont: true`);
  - `notify-send` (libnotify) for long-command notifications. Without it the hook stays silent.

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

7. Source the OSC 133 prompt marks from `~/.zshrc`:

   ```sh
   echo "source $(pwd)/shell/osc133.zsh" >> ~/.zshrc
   ```

> **Note:** `omarchy refresh tmux` restores the stock config and will replace the
> `~/.config/tmux/tmux.conf` symlink. Re-run step 2 if that happens.

TPM is also auto-installed on first tmux start if not already present.

## Notes

- extrakto is bound to `prefix + u`, not its default `prefix + Tab`, which belongs to last-window / switch-mode here.
- Hook commands run in the context of the pane that fired them. Don't pass `-t '#{hook_pane}'` inside a hook: the pane formats then expand empty. That's why the long-command notification lives in `scripts/notify-command-finished.sh`, which queries tmux itself.
- Claude Code's terminal progress bar (OSC 9;4) doesn't reach tmux's own parser, so `#{pane_pb_progress}` stays empty for it. Agent state comes from workmux instead.
