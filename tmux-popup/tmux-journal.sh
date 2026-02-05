#!/usr/bin/env bash

set -euo pipefail

JOURNAL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/notes/journal"

popup() {
  local session="journal"
  local session_id

  if ! tmux has -t "$session" 2>/dev/null; then
    # Create session with a shell first (no command yet)
    # This prevents the race where the command exits before we can attach
    session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}')"
    tmux set-option -s -t "$session_id" key-table popup
    tmux set-option -s -t "$session_id" status off
    tmux set-option -s -t "$session_id" prefix None
    tmux set-option -s -t "$session_id" detach-on-destroy on
    tmux send-keys -t "$session_id" "exec tmux-journal.sh _popup" Enter
    session="$session_id"
  fi

  exec tmux attach -t "$session" >/dev/null
}

commit_note() {
  # Only commit if there are actual changes
  git -C "$JOURNAL_DIR" add "$JOURNAL_DIR"
  if ! git -C "$JOURNAL_DIR" diff --cached --quiet; then
    git -C "$JOURNAL_DIR" commit -m "Update journal" || return 1
    # Push in background to avoid blocking
    git -C "$JOURNAL_DIR" push origin &>/dev/null &
  fi
}

open_journal() {
  # Set sandbox project for nvim to access journal directory
  NVIM_SANDBOX_PROJECT="$JOURNAL_DIR" \
    nvim --cmd "lua require('notes.tmux-popup')" -c "Journal" +'nnoremap q :wq<CR>'
  commit_note
}

if [[ ${1:-} == "_popup" ]]; then
  open_journal
else
  popup
fi
