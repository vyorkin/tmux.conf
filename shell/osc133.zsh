# Mark prompts and command output with OSC 133 (semantic prompts) so tmux can
# jump between prompts in copy mode and, on tmux 3.8+, fire the
# pane-command-finished hook. Starship doesn't emit these marks itself.
#
# Source it from ~/.zshrc after the prompt is set up.

[[ -n $TMUX ]] || return 0

typeset -g _osc133_ran=0

_osc133_precmd() {
  local ret=$?
  # D: the previous command finished, with its exit status
  (( _osc133_ran )) && printf '\e]133;D;%s\a' "$ret"
  _osc133_ran=0
  # A: a new prompt starts here
  printf '\e]133;A\a'
}

_osc133_preexec() {
  _osc133_ran=1
  # C: command output starts here
  printf '\e]133;C\a'
}

# Run first, so $? is still the command's status and not another hook's.
precmd_functions=(_osc133_precmd ${precmd_functions:#_osc133_precmd})
preexec_functions=(_osc133_preexec ${preexec_functions:#_osc133_preexec})
