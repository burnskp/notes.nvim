#!/usr/bin/env bash

set -euo pipefail

JOURNAL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/notes/journal"

# Lua code to set note-friendly options
# read returns non-zero at EOF, which is expected
read -r -d '' NOTE_LUA <<'EOF' || true
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "no"
vim.diagnostic.enable(false, { bufnr = 0 })
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = "nc"
vim.opt_local.foldenable = false
vim.opt_local.spell = true
vim.opt_local.textwidth = 80

vim.schedule(
  function()
    require('lualine').hide()
    vim.opt.laststatus = 0
    vim.api.nvim_set_keymap('n', '<Esc>', '<cmd>silent !tmux detach<CR>', {noremap = true, silent = true})
  end
)
EOF

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
  # Write the Lua config to a temp file
  local lua_tmp
  lua_tmp=$(mktemp /tmp/note_lua.XXXXXX.lua)
  echo "$NOTE_LUA" >"$lua_tmp"
  nvim --cmd "luafile $lua_tmp" -c "Journal" +'nnoremap q :wq<CR>'

  rm -f "$lua_tmp"
  commit_note
}

if [[ ${1:-} == "_popup" ]]; then
  open_journal
else
  popup
fi
