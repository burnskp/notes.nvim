local M = {}
---@class Notes.Config
local defaultConfig = {
  notesDir = "~/notes",
  mappings = {
    ["<c-n>"] = "createNote",
  },
}

---@param userConfig? Notes.Config
function M.setupPlugin(userConfig)
  M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})
  M.config.notesDir = vim.fs.normalize(M.config.notesDir)
end

return M
