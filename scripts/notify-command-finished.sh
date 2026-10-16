#!/bin/sh
# Desktop notification when a long command finishes in a pane you aren't
# looking at. Called by the pane-command-finished hook (tmux 3.8+) with the
# pane id; the command timing comes from the shell's OSC 133 marks.

pane=$1
min_seconds=${TMUX_NOTIFY_MIN_SECONDS:-10}

command -v notify-send >/dev/null || exit 0

IFS='|' read -r duration status visible title <<EOF
$(tmux display -p -t "$pane" '#{pane_command_duration}|#{pane_command_status}|#{&&:#{window_active},#{session_attached}}|#{session_name}:#{window_index} #{window_name}')
EOF

[ "${duration:-0}" -ge "$min_seconds" ] || exit 0
[ "$visible" = 1 ] && exit 0

notify-send -a tmux "$title" "Command finished (exit $status, ${duration}s)"
