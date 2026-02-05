local M = {}

local config = require("notes.config").config

-- Snacks picker implementation
local function snacks_pick(dir, type, opts)
  local Snacks = require("snacks")
  local snacks_opts = {
    prompt = type == "files" and "Find Note:" or "Search Notes: ",
    ignored = true,
    cwd = #dir == 1 and dir[1] or nil,
    dirs = #dir == 1 and nil or dir,
    confirm = function(picker, item)
      picker:close()
      if item then
        opts.on_select(item.file)
      end
    end,
    on_input = function(input)
      if input and input ~= "" then
        opts.on_create(input)
      end
    end,
    actions = {
      createNote = function(picker)
        local filename = picker.input:get()
        picker:close()
        opts.on_create(filename)
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

  Snacks.picker.pick(type, snacks_opts)
end

-- Telescope picker implementation
local function telescope_pick(dir, type, opts)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local search_dirs = dir
  local prompt_title = type == "files" and "Find Note" or "Search Notes"

  local function attach_mappings(prompt_bufnr, map)
    -- Override default select action
    actions.select_default:replace(function()
      local selection = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      if selection then
        local file = selection.path or selection[1]
        opts.on_select(file)
      end
    end)

    -- Add create note mapping
    local create_key = nil
    for key, action in pairs(config.mappings or {}) do
      if action == "createNote" then
        create_key = key
        break
      end
    end

    if create_key then
      map({ "i", "n" }, create_key, function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local input = picker:_get_prompt()
        actions.close(prompt_bufnr)
        opts.on_create(input)
      end)
    end

    return true
  end

  if type == "files" then
    require("telescope.builtin").find_files({
      prompt_title = prompt_title,
      search_dirs = search_dirs,
      attach_mappings = attach_mappings,
    })
  else
    require("telescope.builtin").live_grep({
      prompt_title = prompt_title,
      search_dirs = search_dirs,
      attach_mappings = attach_mappings,
    })
  end
end

-- Main pick function that delegates to the configured picker
function M.pick(dir, type, opts)
  local picker = config.picker or "snacks"

  if picker == "telescope" then
    telescope_pick(dir, type, opts)
  else
    snacks_pick(dir, type, opts)
  end
end

return M
