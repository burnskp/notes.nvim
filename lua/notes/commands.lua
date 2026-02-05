local M = {}

local git = require("notes.git")
local picker = require("notes.picker")

local lastNote = nil

local function getConfig()
  return require("notes.config").config
end

local augroup = vim.api.nvim_create_augroup("NotesGit", { clear = false })

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
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      git.handleGitOperations(note)
    end,
  })
end

local function openFloat(note)
  -- Try Snacks first, fall back to native floating window
  local ok, Snacks = pcall(require, "snacks")
  local config = getConfig()
  if ok then
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
    lastNote = note
    return popup
  end

  -- Native floating window fallback
  local float_opts = config.float_opts or {}
  local width = float_opts.width or 0.8
  local height = float_opts.height or 0.8

  -- Convert percentages to actual dimensions
  local ui = vim.api.nvim_list_uis()[1]
  local win_width = math.floor(ui.width * (width < 1 and width or 1))
  local win_height = math.floor(ui.height * (height < 1 and height or 1))
  local row = math.floor((ui.height - win_height) / 2)
  local col = math.floor((ui.width - win_width) / 2)

  -- Create buffer and load file
  local buf = vim.fn.bufadd(note)
  vim.fn.bufload(buf)
  vim.bo[buf].filetype = "markdown"

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = float_opts.style or "minimal",
    border = float_opts.border or "rounded",
  })

  -- Set up q keymap to save and close
  vim.keymap.set("n", "q", function()
    vim.cmd("write")
    git.handleGitOperations(note)
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })

  lastNote = note
  return { buf = buf, win = win }
end

function M.createNote(dir, name, float)
  if not dir or dir == "" then
    vim.notify("Notes directory not configured", vim.log.levels.ERROR)
    return
  end

  if not name or name == "" then
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
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        git.handleGitOperations(note)
      end,
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
  picker.pick(dir, type, {
    on_select = function(file)
      if float then
        openFloat(file)
      else
        openNote(file)
      end
    end,
    on_create = function(filename)
      if #dir == 1 then
        M.createNote(dir[1], filename, float)
      else
        -- Prompt user to select directory
        vim.ui.select(dir, {
          prompt = "Create note in:",
          format_item = function(d)
            return vim.fn.fnamemodify(d, ":~")
          end,
        }, function(choice)
          if choice then
            M.createNote(choice, filename, float)
          end
        end)
      end
    end,
  })
end

local function projectNotes(type, float)
  local project = getProject()
  if project then
    local dir = getConfig().projectNotesDir .. "/" .. project
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
    M.findNote(float)
  end
end

function M.findNote(float)
  local notesDir = getConfig().notesDir
  makeNotesDir(notesDir)
  M.searchNotes({ notesDir }, "files", float)
end

function M.grepNote(float)
  local notesDir = getConfig().notesDir
  makeNotesDir(notesDir)
  M.searchNotes({ notesDir }, "grep", float)
end

function M.findAllNote(float)
  local config = getConfig()
  M.searchNotes({ config.notesDir, config.projectNotesDir }, "files", float)
end

function M.grepAllNote(float)
  local config = getConfig()
  M.searchNotes({ config.notesDir, config.projectNotesDir }, "grep", float)
end

function M.findProjectNote(float)
  projectNotes("files", float)
end

function M.grepProjectNote(float)
  projectNotes("grep", float)
end

function M.openProjectNote(note, float)
  if not note or note == "" then
    vim.notify("Note name is required", vim.log.levels.WARN)
    return
  end
  local project = getProject()
  if project then
    local dir = getConfig().projectNotesDir .. "/" .. project
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
  local config = getConfig()
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
  local journalDir = getConfig().journalDir
  makeNotesDir(journalDir)
  M.searchNotes({ journalDir }, "files", float)
end

function M.grepJournal(float)
  local journalDir = getConfig().journalDir
  makeNotesDir(journalDir)
  M.searchNotes({ journalDir }, "grep", float)
end

return M
