local M = {}

local config = require("notes.config").config
local notesDir = config.notesDir
local projectNotesDir = config.projectNotesDir

local lastNote = nil

local function makeNotesDir(dir)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

local function getProject()
  local git_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_dir and git_dir ~= "" and vim.fn.isdirectory(git_dir) == 1 then
    return vim.fn.fnamemodify(git_dir, ":t")
  else
    vim.notify("Not in a git project.", vim.log.levels.WARN)
    return nil
  end
end

local function openFloat(note)
  local Snacks = require("snacks")
  local popup = Snacks.win({
    file = note,
    filetype = "markdown",
    border = "rounded",
    width = 0.8,
    height = 0.8,
    style = "minimal",
    bo = {
      modifiable = true,
    },
    keys = {
      q = function(popup)
        vim.cmd("write")
        popup:close()
      end,
    },
  })

  -- Update last opened note
  lastNote = note

  return popup
end

local function createNote(dir, name, float)
  if name == "" then
    name = os.date("%Y%m%d%H%M%S")
  end

  if not name:match("%.md$") then
    name = name .. ".md"
  end

  local note = dir .. "/" .. name

  if float then
    openFloat(note)
  else
    vim.cmd("e " .. note)
  end

  -- If it's a new file, add a title
  if vim.fn.filereadable(note) == 0 then
    local title = name:gsub("%.md$", ""):gsub("(%d%d%d%d)(%d%d)(%d%d)", "%1-%2-%3")
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "# " .. title, "", "" })
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
  end

  -- Update last opened note
  lastNote = note
end

function M.searchNotes(dir, type, float)
  local opts = {
    prompt = type == "files" and "Find Note:" or "Search Notes: ",
    cwd = dir,
    confirm = function(picker, item)
      picker:close()
      if item then
        if float then
          openFloat(dir .. "/" .. item.text)
        else
          vim.cmd("edit " .. dir .. "/" .. item.text)
        end
      end
    end,
    on_input = function(input)
      if input and input ~= "" then
        createNote(dir, input, float)
      end
    end,
    actions = {
      createNote = function(picker)
        local filename = picker.input:get()
        picker:close()
        createNote(dir, filename, float)
      end,
    },
    win = {
      input = {
        keys = (function()
          local keymap = {}
          for key, action in pairs(config.mappings or {}) do
            keymap[key] = {
              action,
              mode = { "n", "i" },
            }
          end
          return keymap
        end)(),
      },
    },
  }

  Snacks.picker.pick(type, opts)
end

local function projectNotes(type, float)
  local project = getProject()
  if project then
    local dir = projectNotesDir .. "/" .. project
    makeNotesDir(dir)
    M.searchNotes(dir, type, float)
  end
end

function M.openLastNote(float)
  if lastNote and vim.fn.filereadable(lastNote) == 1 then
    if float then
      openFloat(lastNote)
    else
      vim.cmd("edit " .. lastNote)
    end
  else
    M.searchNotes("files", float)
  end
end

function M.findNote(float)
  makeNotesDir(notesDir)
  M.searchNotes(notesDir, "files", float)
end

function M.grepNotes(float)
  makeNotesDir(notesDir)
  M.searchNotes(notesDir, "grep", float)
end

function M.findProjectNote(float)
  projectNotes("files", float)
end

function M.grepProjectNotes(float)
  projectNotes("grep", float)
end

return M
