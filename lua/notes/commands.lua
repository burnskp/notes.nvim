local M = {}

local config = require("notes.config").config
local notesDir = config.notesDir

local lastNote = nil

local function openFloat(note)
  local Snacks = require("snacks")
  local popup = Snacks.win({
    file = note,
    filetype = "markdown",
    border = "rounded",
    width = 0.8,
    height = 0.8,
    style = "minimal",
    keys = {
      q = "close",
    },
  })

  -- Update last opened note
  lastNote = note

  return popup
end

local function createNote(name, float)
  if name == "" then
    name = os.date("%Y%m%d%H%M%S")
  end

  if not name:match("%.md$") then
    name = name .. ".md"
  end

  local note = notesDir .. "/" .. name

  if float then
    openFloat(note)
  else
    vim.cmd("edit " .. note)
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

local function searchNotes(type, float)
  local opts = {
    prompt = type == "files" and "Find Note:" or "Search Notes: ",
    cwd = notesDir,
    confirm = function(picker, item)
      picker:close()
      if item then
        if float then
          openFloat(notesDir .. "/" .. item.text)
        else
          vim.cmd("edit " .. notesDir .. "/" .. item.text)
        end
      end
    end,
    on_input = function(input)
      if input and input ~= "" then
        createNote(input, float)
      end
    end,
    actions = {
      createNote = function(picker)
        local filename = picker.input:get()
        picker:close()
        createNote(filename, float)
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

function M.openLastNote(float)
  if lastNote and vim.fn.filereadable(lastNote) == 1 then
    if float then
      openFloat(lastNote)
    else
      vim.cmd("edit " .. lastNote)
    end
  else
    searchNotes("files", float)
  end
end

function M.findNote(float)
  searchNotes("files", float)
end

function M.grepNotes(float)
  searchNotes("grep", float)
end

return M
