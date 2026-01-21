#!/usr/bin/env bash

set -euo pipefail

NOTES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/notes"
EXT=".md"

mkdir -p "$NOTES_DIR"

# Lua code to set note-friendly options
# read returns non-zero at EOF, which is expected
read -r -d '' NOTE_LUA << 'EOF' || true
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
  local session="notes"
  local session_id arg_escaped

  if ! tmux has -t "$session" 2>/dev/null; then
    # Create session with a shell first (no command yet)
    # This prevents the race where fzf exits before we can attach
    session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}')"
    tmux set-option -s -t "$session_id" key-table popup
    tmux set-option -s -t "$session_id" status off
    tmux set-option -s -t "$session_id" prefix None
    tmux set-option -s -t "$session_id" detach-on-destroy on
    # Safely quote the argument to prevent injection
    arg_escaped=$(printf '%q' "${1:-}")
    tmux send-keys -t "$session_id" "exec tmux-notes.sh _popup $arg_escaped" Enter
    session="$session_id"
  fi

  exec tmux attach -t "$session" >/dev/null
}

commit_note() {
  # Only commit if there are actual changes
  git -C "$NOTES_DIR" add "$NOTES_DIR"
  if ! git -C "$NOTES_DIR" diff --cached --quiet; then
    git -C "$NOTES_DIR" commit -m "Update notes" || return 1
    # Push in background to avoid blocking
    git -C "$NOTES_DIR" push origin &>/dev/null &
  fi
}

open_note() {
  local query file target_file
  query=$(echo "$*" | sed -n '1p')
  file=$(echo "$*" | sed -n '2p')

  # Determine target file
  if [[ -n $file && -f $file ]]; then
    target_file="$file"
  elif [[ -n $query ]]; then
    [[ $query == *$EXT ]] || query="${query}${EXT}"
    target_file="$NOTES_DIR/$query"
  else
    # No file selected, nothing to do
    return 0
  fi

  # Write the Lua config to a temp file only when needed
  local lua_tmp
  lua_tmp=$(mktemp /tmp/note_lua.XXXXXX.lua)
  echo "$NOTE_LUA" > "$lua_tmp"

  nvim --cmd "luafile $lua_tmp" +'nnoremap q :wq<CR>' "$target_file"
  rm -f "$lua_tmp"

  commit_note
}

find_notes() {
  cd "$NOTES_DIR" || exit 1
  local fzf_result
  # fzf returns non-zero on cancel/esc, which is fine
  fzf_result=$(FZF_DEFAULT_COMMAND="fd -I '$EXT'" \
    fzf --no-tmux --prompt="Find note: " \
    --preview="bat --style=plain --color=always --line-range=:40 {}" \
    --preview-window=up:40%:wrap \
    --bind "ctrl-n:accept" \
    --bind "ctrl-g:reload:rg --no-ignore --ignore-case --files-with-matches {q} '**/*.md' 2>/dev/null || true" \
    --print-query | sed "s|$NOTES_DIR/||g") || true
  open_note "$fzf_result"
}

grep_notes() {
  local RG_PREFIX="rg --no-ignore --ignore-case --files-with-matches {q} **/*.md"
  cd "$NOTES_DIR" || exit 1
  local result
  # fzf returns non-zero on cancel/esc, which is fine
  result=$(fzf --no-tmux --prompt="Grep notes: " --bind "start:reload:$RG_PREFIX" \
    --bind "change:reload:$RG_PREFIX|| true" \
    --preview="bat --style=plain --color=always --line-range=:40 {}" \
    --preview-window=up:60%:wrap \
    --ansi --disabled \
    --print-query) || true
  open_note "$result"
}

if [[ ${1:-} == "_popup" ]]; then
  if [[ ${2:-} == "grep" ]]; then
    grep_notes
  else
    find_notes
  fi
else
  popup "${1:-}"
fi
