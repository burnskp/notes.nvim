# notes.nvim

simple notes plugin.

## Features

This is a simple notes taking plugin. It uses the Snacks picker to search notes
via name or contents and open them as either a new buffer or a floating window.

## Requirements

[Snacks](https://github.com/folke/snacks.nvim)

## Installation

**Using [lazy.nvim](https://github.com/folke/lazy.nvim)**

```lua
{
  "burnskp/notes.lua",
  dependencies = {
    { "folke/snacks.nvim",
      opts = { picker = { enabled = true } }
    },
  },
  opts = {},
  cmd = { "Notes", "NotesGrep", "LastNote" },
  keys = {
    { "<leader>nF", "<cmd>Notes<CR>",           desc = "Find Notes" },
    { "<leader>nf", "<cmd>Notes float<CR>",     desc = "Find Notes (Float)" },
    { "<leader>nG", "<cmd>NotesGrep<CR>",       desc = "Grep Notes" },
    { "<leader>ng", "<cmd>NotesGrep float<CR>", desc = "Grep Notes (Float)" },
    { "<leader>nn", "<cmd>LastNote float<CR>",  desc = "Open Last Note (Float)" },
  }
},
```

## Default options

```lua
require("notes").setup({
  notesDir = "~/notes",
  mappings = {
    "<C-n>" = createNote
  }
})
```

## Usage

```vimdoc
:Notes {float}

    Find note by filename and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:NotesGrep {float}

    Find note by contents and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:LastNote {float}

    Re-opens the last viewed note

    Parameters:
        {float} (`string?`) opens in a floating window if set to float
```

## Configuration

- notesDir - path to notes
- mappings:
  - createNote - mapping used to create a new note
