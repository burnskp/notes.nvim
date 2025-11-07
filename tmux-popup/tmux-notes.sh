#!/usr/bin/env bash

NOTES_DIR="$HOME/notes"
EXT=".md"

mkdir -p "$NOTES_DIR"

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
    session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}' tmux-notes.sh _popup "$1")"
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
  git -C "$NOTES_DIR" push origin HEAD
}

open_note() {
  query=$(echo "$*" | sed -n '1p')
  file=$(echo "$*" | sed -n '2p')

  # Write the Lua config to a temp file
  local lua_tmp
  lua_tmp=$(mktemp /tmp/note_lua.XXXXXX.lua)
  echo "$NOTE_LUA" >"$lua_tmp"

  if [[ -n $file && -f $file ]]; then
    nvim --cmd "luafile $lua_tmp" +'nnoremap q :wq<CR>' "$file"
  elif [[ -n $query ]]; then
    [[ $query == *$EXT ]] || query="${query}${EXT}"
    local newfile="$NOTES_DIR/$query"
    nvim --cmd "luafile $lua_tmp" +'nnoremap q :wq<CR>' "$newfile"
  fi

  rm -f "$lua_tmp"
  commit_note
}

find_notes() {
  cd "$NOTES_DIR" || exit 1
  open_note "$(FZF_DEFAULT_COMMAND="fd -I '$EXT'" \
    fzf --prompt="Find note: " \
    --preview="bat --style=plain --color=always --line-range=:40 {}" \
    --preview-window=up:40%:wrap \
    --bind "ctrl-n:accept" \
    --bind "ctrl-g:reload:rg --no-ignore --ignore-case --files-with-matches {q} '**/*.md' 2>/dev/null || true" \
    --print-query | sed "s|$NOTES_DIR/||g")"
}

grep_notes() {
  RG_PREFIX="rg --no-ignore --ignore-case --files-with-matches {q} **/*.md"
  cd "$NOTES_DIR" || exit 1
  result=$(fzf --prompt="Grep notes: " --bind "start:reload:$RG_PREFIX" \
    --bind "change:reload:$RG_PREFIX|| true" \
    --preview="bat --style=plain --color=always --line-range=:40 {}" \
    --preview-window=up:60%:wrap \
    --ansi --disabled \
    --print-query)
  open_note "$result"
}

if [[ $1 == "_popup" ]]; then
  if [[ $2 == "grep" ]]; then
    grep_notes "$2"
  else
    find_notes
  fi
else
  popup "$1"
fi
