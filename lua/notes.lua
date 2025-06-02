local M = {}

---@param userConfig? Notes.Config
function M.setup(userConfig)
  require("notes.config").setupPlugin(userConfig)
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

function M.openProjectScratch(float)
  require("notes.commands").openProjectScratch(float)
end

return M
