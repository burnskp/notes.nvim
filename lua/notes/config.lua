local M = {}
local defaultConfig = {
  notesDir = "~/notes/global",
  projectNotesDir = "~/notes/project",
  journalDir = "~/notes/journal",
  journalTemplate = "# %s\n\n",
  picker = "snacks", -- "snacks" or "telescope"
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
  M.config.journalDir = vim.fs.normalize(M.config.journalDir)
end

return M
