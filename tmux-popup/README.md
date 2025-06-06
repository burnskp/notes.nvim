# tmux-notes.sh

A tmux-integrated notes popup for quickly accessing, creating, and searching
Markdown notes using [Neovim](https://neovim.io/) and the
[notes.nvim](https://github.com/burnskp/notes.nvim) plugin.

## Features

- Open a floating tmux popup for note-taking, powered by Neovim.
- Quickly search, preview, and open existing notes using `fzf`.
- Allows hiding the popup by pressing esc in normal mode and then using the tmux
  keybinding to open the popup again where you left off.
- Fuzzy grep for searching within notes using `ripgrep` and `fzf`.

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [Neovim](https://neovim.io/) (with
  [notes.nvim](https://github.com/burnskp/notes.nvim) installed)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`)
- [bat](https://github.com/sharkdp/bat) (for previews)
- [fd](https://github.com/sharkdp/fd) (for fast file finding)

## Installation

1. Place `tmux-notes.sh` somewhere in your `$PATH`, e.g. `~/bin/tmux-notes.sh`
   and make it executable:

   ```sh
   chmod +x ~/bin/tmux-notes.sh
   ```

2. Add the following to your `~/.tmux.conf`:

   ```tmux
   bind n display-popup -w 80% -h 80% -E ~/bin/tmux-notes.sh
   bind N display-popup -w 80% -h 80% -E ~/bin/tmux-notes.sh grep
   ```

3. (Optional) Edit `NOTES_DIR` at the top of the script to set your preferred
   notes directory (default: `~/notes`).

## Usage

- `prefix + n`: Opens the notes popup for browsing/creating notes.
- `prefix + N`: Opens the notes popup in grep mode for searching note contents.

### In the Neovim Popup

- `q`: Save and close the note.
- `<Esc>`: Detach the tmux popup.
