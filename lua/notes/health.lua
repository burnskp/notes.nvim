local M = {}

local function check_directory(dir, name)
  local health = vim.health
  if vim.fn.isdirectory(dir) == 1 then
    -- Check if writable
    local test_file = vim.fs.joinpath(dir, ".notes_health_check")
    local ok = pcall(function()
      local f = io.open(test_file, "w")
      if f then
        f:close()
        os.remove(test_file)
      else
        error("Cannot write")
      end
    end)
    if ok then
      health.ok(name .. " exists and is writable: " .. dir)
    else
      health.warn(name .. " exists but is not writable: " .. dir)
    end
  else
    health.info(name .. " does not exist (will be created on first use): " .. dir)
  end
end

function M.check()
  local health = vim.health
  health.start("notes.nvim")

  -- Check if config is loaded
  local ok, config_mod = pcall(require, "notes.config")
  if not ok or not config_mod.config then
    health.error("Plugin not configured. Call require('notes').setup() first.")
    return
  end

  local config = config_mod.config

  -- Check notes directories
  check_directory(config.notesDir, "Notes directory")
  check_directory(config.projectNotesDir, "Project notes directory")
  check_directory(config.journalDir, "Journal directory")

  -- Check configured picker
  local picker = config.picker or "snacks"
  if picker == "telescope" then
    local telescope_ok, _ = pcall(require, "telescope")
    if telescope_ok then
      health.ok("Telescope is installed (configured picker)")
    else
      health.error("Telescope is configured but not installed. Install telescope.nvim or set picker = 'snacks'")
    end
  else
    local snacks_ok, _ = pcall(require, "snacks")
    if snacks_ok then
      health.ok("Snacks is installed (configured picker)")
    else
      health.error("Snacks is configured but not installed. Install snacks.nvim or set picker = 'telescope'")
    end
  end

  -- Check git if git features are enabled
  if config.git and (config.git.auto_commit or config.git.auto_push) then
    local git_installed = vim.fn.executable("git") == 1
    if git_installed then
      health.ok("Git is installed (git features enabled)")
    else
      health.error("Git features enabled but git is not installed")
    end
  else
    health.info("Git features are disabled")
  end

  -- Check default extension
  local ext = config.default_extension or ".md"
  health.ok("Default extension: " .. ext)
end

return M
