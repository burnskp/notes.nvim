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
  opts = {
    git = {
      auto_commit = true,
      auto_push = true,
    },
  },
  cmd = {"LastNote", "Notes", "NotesAll", "NotesAllGrep", "NotesGrep", "ProjectNote", "ProjectNotes", "ProjectNotesGrep"},
  keys = {
    { "<leader>na", "<cmd>NotesAllGrep float<CR>",        desc = "Grep All Notes (Float)" },
    { "<leader>nA", "<cmd>NotesAllGrep <CR>",             desc = "Grep All Notes" },
    { "<leader>nf", "<cmd>Notes float<CR>",               desc = "Find Notes (Float)" },
    { "<leader>nF", "<cmd>Notes<CR>",                     desc = "Find Notes" },
    { "<leader>ng", "<cmd>NotesGrep float<CR>",           desc = "Grep Notes (Float)" },
    { "<leader>nG", "<cmd>NotesGrep<CR>",                 desc = "Grep Notes" },
    { "<leader>nn", "<cmd>LastNote float<CR>",            desc = "Open Last Note (Float)" },
    { "<leader>np", "<cmd>ProjectNotes float<CR>",        desc = "Find Project Notes (Float)" },
    { "<leader>nP", "<cmd>ProjectNotes<CR>",              desc = "Find Project Notes" },
    { "<leader>ns", "<cmd>ProjectNote scratch float<CR>", desc = "Project Note - Scratch (Float)" },
    { "<leader>nS", "<cmd>ProjectNote scratch<CR>",       desc = "Grep Project NotNote - Scratch" },
    { "<leader>nt", "<cmd>ProjectNote todo float<CR>",    desc = "Project Note - Todo (Float)" },
    { "<leader>nT", "<cmd>ProjectNote todo<CR>",          desc = "Grep Project NotNote - Todo" },
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
  },
  git = {
    auto_commit = false,
    auto_push = false,
    commit_message = "Update notes",
  },
})
```

## Usage

```vimdoc
:LastNote {float}

    Re-opens the last viewed note

    Parameters:
        {float} (`string?`) opens in a floating window if set to float

:Notes {float}

    Find a global note by filename and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:NotesGrep {float}

    Find a global note by contents and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:NotesAll {float}

    Find a global or project note by filename and open them in a new buffer

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

:NotesAllGrep {float}

    Find a global or project note by contents and open them in a new buffer

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

:ProjectNote {float}

    Opens a specific note for the current project.

    Parameters:
      {float} (`string?`) opens in a floating window if set to float

```

## Configuration

- notesDir - path to notes
- projectNotesDir - path to project notes
- git:
  - auto_commit - commit the note on write
  - auto_push = push the commit automatically
  - commit_message - message to use for the commit
- mappings:
  - createNote - mapping used to create a new note
