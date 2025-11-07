#!/usr/bin/env bash

JOURNAL_DIR="$HOME/notes/journal"

# Lua code to set note-friendly options
read -r -d '' NOTE_LUA <<'EOF'
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
  session="notes"

  if ! tmux has -t "$session" 2>/dev/null; then
    session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' tmux-journal.sh _popup)"
    tmux set-option -s -t "$session_id" key-table popup
    tmux set-option -s -t "$session_id" status off
    tmux set-option -s -t "$session_id" prefix None
    tmux set-option -s -t "$session_id" detach-on-destroy on
    session="$session_id"
  fi

  exec tmux attach -t "$session" >/dev/null
}

commit_note() {
  git -C "$NOTES_DIR" add "$NOTES_DIR"
  git -C "$NOTES_DIR" commit -m "Update notes"
}

open_journal() {
  # Write the Lua config to a temp file
  local lua_tmp
  lua_tmp=$(mktemp /tmp/note_lua.XXXXXX.lua)
  echo "$NOTE_LUA" >"$lua_tmp"

  if ! [[ -d "$JOURNAL_DIR/$(date +%Y)" ]]; then
    mkdir "$JOURNAL_DIR/$(date +%Y)"
  fi
  file="$JOURNAL_DIR/$(date +%Y)/$(date +%Y-%m-%d).md"
  nvim --cmd "luafile $lua_tmp" +'nnoremap q :wq<CR>' "$file"

  rm -f "$lua_tmp"
  commit_note
}

if [[ $1 == "_popup" ]]; then
  open_journal
else
  popup
fi
