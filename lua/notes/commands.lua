local M = {}

local config = require("notes.config").config
local git = require("notes.git")
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

local function openNote(note)
  vim.cmd("edit " .. note)
  -- Set up autocommand for git operations on non-float notes
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = bufnr,
    callback = function()
      git.handleGitOperations(note)
    end,
    once = false,
  })
end

local function openFloat(note)
  local Snacks = require("snacks")
  local float_opts = vim.tbl_extend("force", config.float_opts or {}, {
    file = note,
    filetype = "markdown",
    bo = {
      modifiable = true,
    },
    keys = {
      q = function(popup)
        vim.cmd("write")
        git.handleGitOperations(note)
        popup:close()
      end,
    },
  })
  local popup = Snacks.win(float_opts)

  -- Update last opened note
  lastNote = note

  return popup
end

function M.createNote(dir, name, float)
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
    -- Set up autocommand for git operations on non-float notes
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = bufnr,
      callback = function()
        git.handleGitOperations(note)
      end,
      once = false,
    })
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
    ignored = true,
    cwd = #dir == 1 and dir[1] or nil,
    dirs = #dir == 1 and nil or dir,
    confirm = function(picker, item)
      picker:close()
      if item then
        if float then
          openFloat(item.file)
        else
          openNote(item.file)
        end
      end
    end,
    on_input = function(input)
      if input and input ~= "" then
        M.createNote(dir[1], input, float)
      end
    end,
    actions = {
      createNote = function(picker)
        local filename = picker.input:get()
        picker:close()
        M.createNote(dir[1], filename, float)
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
    M.searchNotes({ dir }, type, float)
  end
end

function M.openLastNote(float)
  if lastNote and vim.fn.filereadable(lastNote) == 1 then
    if float then
      openFloat(lastNote)
    else
      openNote(lastNote)
    end
  else
    M.findNotes(float)
  end
end

function M.findNote(float)
  makeNotesDir(notesDir)
  M.searchNotes({ notesDir }, "files", float)
end

function M.grepNotes(float)
  makeNotesDir(notesDir)
  M.searchNotes({ notesDir }, "grep", float)
end

function M.findAllNote(float)
  M.searchNotes({ notesDir, projectNotesDir }, "files", float)
end

function M.grepAllNotes(float)
  M.searchNotes({ notesDir, projectNotesDir }, "grep", float)
end

function M.findProjectNote(float)
  projectNotes("files", float)
end

function M.grepProjectNotes(float)
  projectNotes("grep", float)
end

function M.openProjectNote(note, float)
  local project = getProject()
  if project then
    local dir = projectNotesDir .. "/" .. project
    makeNotesDir(dir)
    local note_path = dir .. "/" .. note .. ".md"
    if float then
      openFloat(note_path)
    else
      openNote(note_path)
    end
  end
end

function M.openJournal(float)
  local journalDir = config.journalDir
  local date = os.date("*t")
  local year = string.format("%04d", date.year)
  local filename = string.format("%04d-%02d-%02d.md", date.year, date.month, date.day)

  local year_dir = journalDir .. "/" .. year
  makeNotesDir(year_dir)

  local journal_path = year_dir .. "/" .. filename
  local is_new = vim.fn.filereadable(journal_path) == 0

  if float then
    openFloat(journal_path)
  else
    openNote(journal_path)
  end

  -- If it's a new file, add the template content
  if is_new then
    local day_of_week = os.date("%A")
    local date_str = string.format("%04d-%02d-%02d %s", date.year, date.month, date.day, day_of_week)
    local template = string.format(config.journalTemplate, date_str)
    local lines = vim.split(template, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    -- Position cursor after the template
    vim.api.nvim_win_set_cursor(0, { #lines, 0 })
  end

  -- Update last opened note
  lastNote = journal_path
end

function M.findJournal(float)
  local journalDir = config.journalDir
  makeNotesDir(journalDir)
  M.searchNotes({ journalDir }, "files", float)
end

function M.grepJournal(float)
  local journalDir = config.journalDir
  makeNotesDir(journalDir)
  M.searchNotes({ journalDir }, "grep", float)
end

return M
