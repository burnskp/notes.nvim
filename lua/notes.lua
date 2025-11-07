local M = {}

function M.setup(userConfig)
  require("notes.config").setupPlugin(userConfig)
end

function M.findAllNote(float)
  require("notes.commands").findAllNote(float)
end

function M.grepAllNotes(float)
  require("notes.commands").grepAllNotes(float)
end

function M.findNote(float)
  require("notes.commands").findNote(float)
end

function M.grepNotes(float)
  require("notes.commands").grepNotes(float)
end

function M.findProjectNote(float)
  require("notes.commands").findProjectNote(float)
end

function M.grepProjectNotes(float)
  require("notes.commands").grepProjectNotes(float)
end

function M.lastNote(float)
  require("notes.commands").openLastNote(float)
end

function M.openProjectNote(note, float)
  require("notes.commands").openProjectNote(note, float)
end

function M.createNote(note)
  local dir = require("notes.config").config.notesDir
  require("notes.commands").createNote(dir, note, false)
end

function M.openJournal(float)
  require("notes.commands").openJournal(float)
end

function M.findJournal(float)
  require("notes.commands").findJournal(float)
end

function M.grepJournal(float)
  require("notes.commands").grepJournal(float)
end

return M
