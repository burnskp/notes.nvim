local notes = require("notes")

vim.api.nvim_create_user_command("Notes", function(opts)
  local float = opts.args == "float"
  notes.findNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesGrep", function(opts)
  local float = opts.args == "float"
  notes.grepNotes(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("LastNote", function(opts)
  local float = opts.args == "float"
  notes.lastNote(float)
end, { nargs = "?" })
