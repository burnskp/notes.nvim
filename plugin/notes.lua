local notes = require("notes")

vim.api.nvim_create_user_command("CreateNote", function(opts)
  notes.createNote(opts.args)
end, { nargs = "*" })

vim.api.nvim_create_user_command("Notes", function(opts)
  local float = opts.args:lower() == "float"
  notes.findNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesGrep", function(opts)
  local float = opts.args:lower() == "float"
  notes.grepNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesAll", function(opts)
  local float = opts.args:lower() == "float"
  notes.findAllNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("NotesAllGrep", function(opts)
  local float = opts.args:lower() == "float"
  notes.grepAllNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNotes", function(opts)
  local float = opts.args:lower() == "float"
  notes.findProjectNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNotesGrep", function(opts)
  local float = opts.args:lower() == "float"
  notes.grepProjectNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("ProjectNote", function(opts)
  local raw_args = vim.trim(opts.args or "")
  local float = false

  if raw_args:sub(-6):lower() == " float" then
    raw_args = vim.trim(raw_args:sub(1, -7))
    float = true
  elseif raw_args:lower() == "float" then
    raw_args = ""
    float = true
  end

  local note = raw_args
  if not note or note == "" then
    vim.notify("Usage: :ProjectNote <name> [float]", vim.log.levels.WARN)
    return
  end

  notes.openProjectNote(note, float)
end, { nargs = "*" })

vim.api.nvim_create_user_command("LastNote", function(opts)
  local float = opts.args:lower() == "float"
  notes.lastNote(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("Journal", function(opts)
  local float = opts.args:lower() == "float"
  notes.openJournal(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("JournalFind", function(opts)
  local float = opts.args:lower() == "float"
  notes.findJournal(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("JournalGrep", function(opts)
  local float = opts.args:lower() == "float"
  notes.grepJournal(float)
end, { nargs = "?" })

vim.api.nvim_create_user_command("DeleteNote", function()
  notes.deleteNote()
end, {})

vim.api.nvim_create_user_command("RenameNote", function(opts)
  notes.renameNote(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })
