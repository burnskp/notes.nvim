local notes = require("notes")

vim.api.nvim_create_user_command("CreateNote", function(opts)
  notes.createNote(opts.args)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Notes", function(opts)
  local float = opts.args == "float"
  notes.findNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesGrep", function(opts)
  local float = opts.args == "float"
  notes.grepNotes(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesAll", function(opts)
  local float = opts.args == "float"
  notes.findAllNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesAllGrep", function(opts)
  local float = opts.args == "float"
  notes.grepAllNotes(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNotes", function(opts)
  local float = opts.args == "float"
  notes.findProjectNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNotesGrep", function(opts)
  local float = opts.args == "float"
  notes.grepProjectNotes(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNote", function(opts)
  local args = vim.split(opts.args or "", " ")
  local note = args[1]
  local float = args[2] == "float"
  notes.openProjectNote(note, float)
end, { nargs = "*" })

vim.api.nvim_create_user_command("LastNote", function(opts)
  local float = opts.args == "float"
  notes.lastNote(float)
end, { nargs = "?" })
