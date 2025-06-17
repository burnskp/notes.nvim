local M = {}
local defaultConfig = {
  notesDir = "~/notes/global",
  projectNotesDir = "~/notes/project",
  mappings = {
    ["<c-n>"] = "createNote",
  },
  float_opts = {
    border = "rounded",
    width = 0.8,
    height = 0.8,
    style = "minimal",
  },
  git = {
    auto_commit = false,
    auto_push = false,
    commit_message = "Update notes",
  },
}

function M.setupPlugin(userConfig)
  M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})
  M.config.notesDir = vim.fs.normalize(M.config.notesDir)
  M.config.projectNotesDir = vim.fs.normalize(M.config.projectNotesDir)
end

return M
