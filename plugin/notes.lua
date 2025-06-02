local notes = require("notes")

vim.api.nvim_create_user_command("Notes", function(opts)
  local float = opts.args == "float"
  notes.findNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesGrep", function(opts)
  local float = opts.args == "float"
  notes.grepNotes(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNotes", function(opts)
  local float = opts.args == "float"
  notes.findProjectNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNotesGrep", function(opts)
  local float = opts.args == "float"
  notes.grepProjectNotes(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectScratch", function(opts)
  local float = opts.args == "float"
  notes.openProjectScratch(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("LastNote", function(opts)
  local float = opts.args == "float"
  notes.lastNote(float)
end, { nargs = "?" })
