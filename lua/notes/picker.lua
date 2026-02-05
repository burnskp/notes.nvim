local M = {}

local notes_config = require("notes.config")

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
          for key, action in pairs(notes_config.config.mappings or {}) do
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
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local prompt_title = type == "files" and "Find Note" or "Search Notes"

  -- For single directory, use cwd to show relative paths (like snacks)
  -- For multiple directories, use search_dirs with custom path_display
  local single_dir = #dir == 1
  local cwd = single_dir and dir[1] or nil
  local search_dirs = single_dir and nil or dir

  -- Custom path display to strip notes directory prefixes when using multiple dirs
  local path_display
  if not single_dir then
    path_display = function(_, path)
      -- Strip any of the search directories from the path
      for _, d in ipairs(dir) do
        local prefix = d:gsub("/$", "") .. "/"
        if path:sub(1, #prefix) == prefix then
          return path:sub(#prefix + 1)
        end
      end
      return path
    end
  end

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
    for key, action in pairs(notes_config.config.mappings or {}) do
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
      cwd = cwd,
      search_dirs = search_dirs,
      path_display = path_display,
      attach_mappings = attach_mappings,
    })
  else
    require("telescope.builtin").live_grep({
      prompt_title = prompt_title,
      cwd = cwd,
      search_dirs = search_dirs,
      path_display = path_display,
      attach_mappings = attach_mappings,
    })
  end
end

-- Main pick function that delegates to the configured picker
function M.pick(dir, type, opts)
  local picker = notes_config.config.picker or "snacks"

  if picker == "telescope" then
    local ok, _ = pcall(require, "telescope")
    if not ok then
      vim.notify(
        "Telescope is not installed. Please install telescope.nvim or set picker = 'snacks'",
        vim.log.levels.ERROR
      )
      return
    end
    telescope_pick(dir, type, opts)
  else
    local ok, _ = pcall(require, "snacks")
    if not ok then
      vim.notify(
        "Snacks is not installed. Please install snacks.nvim or set picker = 'telescope'",
        vim.log.levels.ERROR
      )
      return
    end
    snacks_pick(dir, type, opts)
  end
end

return M
