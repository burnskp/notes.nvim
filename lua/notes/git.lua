local M = {}

local config = require("notes.config").config

local function isGitRepo(dir)
  local git_dir = vim.fn.systemlist("cd " .. vim.fn.shellescape(dir) .. " && git rev-parse --git-dir 2>/dev/null")[1]
  return git_dir and git_dir ~= ""
end

local function gitCommit(file)
  local dir = vim.fn.fnamemodify(file, ":h")
  if not isGitRepo(dir) then
    vim.notify(dir .. " is not a git repo")
    return
  end

  local cmd = string.format(
    "cd %s && git add %s && git commit -m %s",
    vim.fn.shellescape(dir),
    vim.fn.shellescape(vim.fn.fnamemodify(file, ":t")),
    vim.fn.shellescape(config.git.commit_message)
  )

  vim.fn.system(cmd)
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

  local cmd = string.format("cd %s && git push", vim.fn.shellescape(dir))
  vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code == 0 then
    vim.notify("Note pushed to git", vim.log.levels.INFO)
  else
    vim.notify("Failed to push note to git", vim.log.levels.WARN)
  end
end

function M.handleGitOperations(file)
  if config.git.auto_commit then
    gitCommit(file)
    if config.git.auto_push then
      gitPush(file)
    end
  end
end

return M
