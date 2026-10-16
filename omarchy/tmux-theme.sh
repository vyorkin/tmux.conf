#!/bin/bash
# Keep tmux colors in sync with the active Omarchy theme.
#
# Installed as an Omarchy `theme-set` (and `post-boot`) hook, so it runs after
# every `omarchy theme set`. It renders a tmux config from the active
# colors.toml and sources it into the running tmux server. The very same file
# is sourced by ~/.tmux.conf on startup, so new servers pick up the theme too.
#
# Colors are resolved through omarchy-theme-color, the same parser every other
# Omarchy consumer uses, so tmux matches the rest of the desktop exactly.

set -euo pipefail

OMARCHY_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current"
COLORS_FILE="$OMARCHY_STATE/theme/colors.toml"
THEME_NAME="$(cat "$OMARCHY_STATE/theme.name" 2>/dev/null || echo unknown)"

OUT_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
OUT_FILE="$OUT_DIR/omarchy-theme.conf"

[[ -f $COLORS_FILE ]] || exit 0

mkdir -p "$OUT_DIR"

color() {
  local key="$1" fallback="${2:-}"
  if [[ -n $fallback ]]; then
    omarchy-theme-color --file "$COLORS_FILE" "$key" "$fallback" 2>/dev/null || true
  else
    omarchy-theme-color --file "$COLORS_FILE" "$key" 2>/dev/null || true
  fi
}

bg=$(color background color0)
fg=$(color foreground color7)
muted=$(color muted dark_foreground)
accent=$(color accent blue)
light_bg=$(color lighter_background background)
green=$(color green color2)

: "${bg:=#000000}"
: "${fg:=#ffffff}"
: "${muted:=$fg}"
: "${accent:=$fg}"
: "${light_bg:=$bg}"
: "${green:=$accent}"

# tmux-continuum auto-saves through a #() hook it prepends to status-right on
# load. Re-sourcing this file replaces status-right, so carry the hook along.
continuum_save=""
plugin_dir=$(tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH 2>/dev/null | cut -d= -f2-)
continuum_script="${plugin_dir:-$HOME/.config/tmux/plugins/}tmux-continuum/scripts/continuum_save.sh"
[[ -x $continuum_script ]] && continuum_save="#($continuum_script)"

cat >"$OUT_FILE" <<EOF
# Generated from Omarchy theme "$THEME_NAME" by omarchy/tmux-theme.sh.
# Do not edit by hand — rewritten on every \`omarchy theme set\`.

set -g status-style "bg=$bg,fg=$fg"
set -g status-left-length 30
set -g status-right-length 100

set -g status-left "#[fg=$bg,bg=$accent,bold] #S #[fg=$fg,bg=$bg] "
set -g status-right "$continuum_save#[fg=$accent]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=$muted]#h "

# #{@workmux_status} shows workmux agent icons (working / waiting / done).
set -g window-status-format "#[fg=$muted] #I:#W#{?@workmux_status, #{@workmux_status},} "
set -g window-status-current-format "#[fg=$accent,bold] #I:#W#{?@workmux_status, #{@workmux_status},} "
set -g window-status-activity-style "fg=$green,bg=$bg"

set -g pane-border-style "fg=$muted"
set -g pane-active-border-style "fg=$accent"

set -g message-style "bg=$bg,fg=$accent"
set -g message-command-style "bg=$bg,fg=$accent"
set -g mode-style "bg=$accent,fg=$bg"

# Keep panes flat: no dimming of inactive panes.
set -g window-style "bg=$bg"
set -g window-active-style "bg=$bg"

# tmux-floax reads its colors from @options at load time and from the
# environment afterwards, so set both to recolor it on theme change.
set -g @floax-border-color "$accent"
set -g @floax-text-color "$fg"
set-environment -g FLOAX_BORDER_COLOR "$accent"
set-environment -g FLOAX_TEXT_COLOR "$fg"

setw -g clock-mode-colour "$accent"
set -g clock-mode-style 24
EOF

# Apply to the running server, if any.
if tmux list-sessions >/dev/null 2>&1; then
  pane=$(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | head -n1)
  if [[ -n $pane ]]; then
    tmux source-file -t "$pane" "$OUT_FILE" 2>/dev/null || true
  fi
  tmux refresh-client -S 2>/dev/null || true
fi
