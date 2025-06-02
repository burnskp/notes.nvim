# notes.nvim

simple notes plugin.

## Features

This is a simple notes taking plugin. It uses the Snacks picker to search notes
via name or contents and open them as either a new buffer or a floating window.

It also supports project-specific notes that are stored in the projects
directory. A project is a git repo and the notes are stored in a subdirectory
with the git repo's name.

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
    { "<leader>nf", "<cmd>Notes float<CR>",            desc = "Find Notes (Float)" },
    { "<leader>nF", "<cmd>Notes<CR>",                  desc = "Find Notes" },
    { "<leader>ng", "<cmd>NotesGrep float<CR>",        desc = "Grep Notes (Float)" },
    { "<leader>nG", "<cmd>NotesGrep<CR>",              desc = "Grep Notes" },
    { "<leader>np", "<cmd>ProjectNotes float<CR>",     desc = "Find Project Notes (Float)" },
    { "<leader>nP", "<cmd>ProjectNotes<CR>",           desc = "Find Project Notes" },
    { "<leader>ns", "<cmd>ProjectNotesGrep float<CR>", desc = "Grep Project Notes (Float)" },
    { "<leader>nS", "<cmd>ProjectNotesGrep<CR>",       desc = "Grep Project Notes" },
    { "<leader>nn", "<cmd>LastNote float<CR>",         desc = "Open Last Note (Float)" },
  }
},
```

## Default options

```lua
require("notes").setup({
  notesDir = "~/notes/global",
  projectNotesDir = "~/notes/projects",
  mappings = {
    "<C-n>" = createNote
  }
})
```

## Usage

```vimdoc
:LastNote {float}

    Re-opens the last viewed note

    Parameters:
        {float} (`string?`) opens in a floating window if set to float

:Notes {float}

    Find note by filename and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:NotesGrep {float}

    Find note by contents and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:ProjectNotes {float}

    Find a projet note by filename and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:ProjectNotesGrep {float}

    Find a project note by contents and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:ProjectScratch {float}

    Opens scratch.md for the current project.

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

```

## Configuration

- notesDir - path to notes
- projectNotesDir - path to project notes
- mappings:
  - createNote - mapping used to create a new note
