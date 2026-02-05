local M = {}

local function getConfig()
  return require("notes.config").config
end

local function isGitRepo(dir)
  local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--git-dir" })
  return vim.v.shell_error == 0 and result[1] and result[1] ~= ""
end

local function gitCommit(file)
  local dir = vim.fn.fnamemodify(file, ":h")
  if not isGitRepo(dir) then
    vim.notify(dir .. " is not a git repo")
    return
  end

  local filename = vim.fn.fnamemodify(file, ":t")
  local config = getConfig()

  -- Add the file
  vim.fn.system({ "git", "-C", dir, "add", filename })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to stage note for git", vim.log.levels.WARN)
    return
  end

  -- Commit the file
  vim.fn.system({ "git", "-C", dir, "commit", "-m", config.git.commit_message })
  local exit_code = vim.v.shell_error

  if exit_code == 0 then
    vim.notify("Note committed to git", vim.log.levels.INFO)
  elseif exit_code ~= 1 then -- exit code 1 is "nothing to commit"
    vim.notify("Failed to commit note to git", vim.log.levels.WARN)
  end
end

local function gitPush(file)
  local dir = vim.fn.fnamemodify(file, ":h")
  if not isGitRepo(dir) then
    return
  end

  vim.fn.jobstart({ "git", "-C", dir, "push" }, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          vim.notify("Note pushed to git", vim.log.levels.INFO)
        else
          vim.notify("Failed to push note to git", vim.log.levels.WARN)
        end
      end)
    end,
  })
end

function M.handleGitOperations(file)
  local config = getConfig()
  if config.git.auto_commit then
    gitCommit(file)
    if config.git.auto_push then
      gitPush(file)
    end
  end
end

return M
