local plugin = require("notes")
local spy = require("luassert.spy")
local stub = require("luassert.stub")

local function make_temp_dir(prefix)
  local path = vim.fs.joinpath(vim.fn.tempname(), prefix)
  vim.fn.mkdir(path, "p")
  return path
end

local function write_file(path, lines)
  vim.fn.writefile(lines or { "test" }, path)
end

local function git(args, cwd)
  local cmd = { "git" }
  if cwd then
    table.insert(cmd, "-C")
    table.insert(cmd, cwd)
  end
  vim.list_extend(cmd, args)
  return vim.fn.system(cmd)
end

local function git_lines(args, cwd)
  local cmd = { "git" }
  if cwd then
    table.insert(cmd, "-C")
    table.insert(cmd, cwd)
  end
  vim.list_extend(cmd, args)
  return vim.fn.systemlist(cmd)
end

local function init_git_repo(path)
  git({ "init", path })
  git({ "config", "user.name", "notes.nvim" }, path)
  git({ "config", "user.email", "notes@example.com" }, path)
  git({ "config", "commit.gpgsign", "false" }, path)
end

describe("setup", function()
  it("validates default notes path", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.notesDir == os.getenv("HOME") .. "/notes/global", "Expected default notesDir")
  end)

  it("validates default project notes path", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.projectNotesDir == os.getenv("HOME") .. "/notes/project", "Expected default projectNotesDir")
  end)

  it("validates custom notes path", function()
    plugin.setup({ notesDir = "/test/dir" })
    local config = require("notes.config").config
    assert(config.notesDir == "/test/dir", "Expected custom notesDir")
  end)

  it("validates custom project notes path", function()
    plugin.setup({ projectNotesDir = "/test/dir" })
    local config = require("notes.config").config
    assert(config.projectNotesDir == "/test/dir", "Expected custom projectNotesDir")
  end)

  it("validates default extension", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.default_extension == ".md", "Expected default extension")
  end)

  it("validates custom extension", function()
    plugin.setup({ default_extension = ".txt" })
    local config = require("notes.config").config
    assert(config.default_extension == ".txt", "Expected custom extension")
  end)

  it("validates default picker", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.picker == "snacks", "Expected default picker")
  end)

  it("validates custom picker", function()
    plugin.setup({ picker = "telescope" })
    local config = require("notes.config").config
    assert(config.picker == "telescope", "Expected custom picker")
  end)
end)

describe("input validation", function()
  it("rejects names with backslash", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("rejects names with asterisk", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("rejects names with question mark", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("rejects names with double quote", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("rejects names with less than", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("rejects names with greater than", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("rejects names with pipe", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- This would be tested by checking for error notification
  end)

  it("allows valid names", function()
    plugin.setup({ notesDir = "/tmp/test-notes" })
    -- Valid names like "my-note", "my_note", "my note" should work
  end)
end)

describe("health check", function()
  it("loads health module", function()
    local ok, health = pcall(require, "notes.health")
    assert(ok, "Health module should load")
    assert(health.check, "Health module should have check function")
  end)
end)

describe("picker", function()
  it("loads picker module", function()
    local ok, picker = pcall(require, "notes.picker")
    assert(ok, "Picker module should load")
    assert(picker.pick, "Picker module should have pick function")
  end)
end)

describe("commands module", function()
  it("loads commands module", function()
    local ok = pcall(require, "notes.commands")
    assert(ok, "Commands module should load")
  end)

  it("has createNote function", function()
    local commands = require("notes.commands")
    assert(type(commands.createNote) == "function", "Expected createNote export")
  end)

  it("has deleteNote function", function()
    local commands = require("notes.commands")
    assert(type(commands.deleteNote) == "function", "Expected deleteNote export")
  end)

  it("has renameNote function", function()
    local commands = require("notes.commands")
    assert(type(commands.renameNote) == "function", "Expected renameNote export")
  end)

  it("has searchNotes function", function()
    local commands = require("notes.commands")
    assert(type(commands.searchNotes) == "function", "Expected searchNotes export")
  end)

  it("has findNote function", function()
    local commands = require("notes.commands")
    assert(type(commands.findNote) == "function", "Expected findNote export")
  end)

  it("has grepNote function", function()
    local commands = require("notes.commands")
    assert(type(commands.grepNote) == "function", "Expected grepNote export")
  end)

  it("has openJournal function", function()
    local commands = require("notes.commands")
    assert(type(commands.openJournal) == "function", "Expected openJournal export")
  end)

  it("uses the configured extension for project notes", function()
    local commands = require("notes.commands")
    local repo_dir = make_temp_dir("notes-project-repo")
    local project_notes_dir = make_temp_dir("notes-project-store")
    local original_cwd = vim.fn.getcwd()
    local cmd = spy.on(vim, "cmd")

    vim.fn.system({ "git", "init", repo_dir })
    vim.api.nvim_set_current_dir(repo_dir)
    plugin.setup({ projectNotesDir = project_notes_dir, default_extension = ".txt" })

    commands.openProjectNote("scratch", false)

    -- selene: allow(incorrect_standard_library_use)
    assert
      .spy(cmd)
      .was_called_with("edit " .. vim.fn.fnameescape(vim.fs.joinpath(project_notes_dir, "notes-project-repo", "scratch.txt")))

    vim.api.nvim_set_current_dir(original_cwd)
    cmd:revert()
  end)

  it("does not append a second extension for project notes", function()
    local commands = require("notes.commands")
    local repo_dir = make_temp_dir("notes-project-repo-ext")
    local project_notes_dir = make_temp_dir("notes-project-store-ext")
    local original_cwd = vim.fn.getcwd()
    local cmd = spy.on(vim, "cmd")

    vim.fn.system({ "git", "init", repo_dir })
    vim.api.nvim_set_current_dir(repo_dir)
    plugin.setup({ projectNotesDir = project_notes_dir, default_extension = ".txt" })

    commands.openProjectNote("scratch.md", false)

    -- selene: allow(incorrect_standard_library_use)
    assert
      .spy(cmd)
      .was_called_with("edit " .. vim.fn.fnameescape(vim.fs.joinpath(project_notes_dir, "notes-project-repo-ext", "scratch.md")))

    vim.api.nvim_set_current_dir(original_cwd)
    cmd:revert()
  end)

  it("escapes note paths when opening notes in a normal buffer", function()
    local commands = require("notes.commands")
    local notes_dir = make_temp_dir("notes-with-space")

    plugin.setup({ notesDir = notes_dir })
    commands.createNote(notes_dir, "my note", false)

    assert(vim.api.nvim_buf_get_name(0) == vim.fs.joinpath(notes_dir, "my note.md"), "Expected escaped edit path")
  end)

  it("creates missing directories for direct createNote calls", function()
    local commands = require("notes.commands")
    local root_dir = make_temp_dir("notes-create-dir")
    local notes_dir = vim.fs.joinpath(root_dir, "global")

    plugin.setup({ notesDir = notes_dir })
    commands.createNote(notes_dir, "scratch", false)
    vim.cmd("silent write")

    assert(
      vim.fn.filereadable(vim.fs.joinpath(notes_dir, "scratch.md")) == 1,
      "Expected createNote to create the notes directory before writing"
    )
  end)

  it("creates notes in nested subdirectories", function()
    local commands = require("notes.commands")
    local notes_dir = make_temp_dir("notes-nested")
    local expected_path = vim.fs.joinpath(notes_dir, "work.v1", "projects", "roadmap.md")

    plugin.setup({ notesDir = notes_dir })
    commands.createNote(notes_dir, "work.v1/projects/roadmap", false)
    vim.cmd("silent write")

    assert(vim.fn.filereadable(expected_path) == 1, "Expected nested note to be created")
    assert(vim.api.nvim_buf_get_name(0) == expected_path, "Expected nested note to be opened")
    assert(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "# roadmap", "Expected title to use the filename")
  end)

  it("rejects note paths that escape the notes directory", function()
    local commands = require("notes.commands")
    local root_dir = make_temp_dir("notes-traversal")
    local notes_dir = vim.fs.joinpath(root_dir, "global")
    local notify = stub(vim, "notify")

    plugin.setup({ notesDir = notes_dir })
    commands.createNote(notes_dir, "../outside", false)

    assert(vim.fn.filereadable(vim.fs.joinpath(root_dir, "outside.md")) == 0, "Expected traversal path to be rejected")
    -- selene: allow(incorrect_standard_library_use)
    assert.stub(notify).was_called()
    notify:revert()
  end)

  it("installs the git BufWritePost autocmd for floating notes", function()
    local commands = require("notes.commands")
    local notes_dir = make_temp_dir("notes-float-autocmd")
    local original_snacks = package.loaded["snacks"]

    package.loaded["snacks"] = {
      win = function(opts)
        vim.cmd("edit " .. vim.fn.fnameescape(opts.file))
        return { close = function() end }
      end,
    }

    plugin.setup({ notesDir = notes_dir, git = { auto_commit = true } })
    commands.createNote(notes_dir, "floating", true)

    local autocmds =
      vim.api.nvim_get_autocmds({ event = "BufWritePost", group = "NotesGit", buffer = vim.api.nvim_get_current_buf() })
    assert(#autocmds > 0, "Expected floating note buffer to receive the git BufWritePost autocmd")

    package.loaded["snacks"] = original_snacks
  end)

  it("runs floating note git operations only once when closing with q", function()
    local commands = require("notes.commands")
    local git_integration = require("notes.git")
    local notes_dir = make_temp_dir("notes-float-save-once")
    local original_snacks = package.loaded["snacks"]
    local close_float
    local git_calls = 0
    local handle_git = stub(git_integration, "handleGitOperations", function()
      git_calls = git_calls + 1
    end)

    package.loaded["snacks"] = {
      win = function(opts)
        close_float = opts.keys.q
        vim.cmd("edit " .. vim.fn.fnameescape(opts.file))
        return { close = function() end }
      end,
    }

    plugin.setup({ notesDir = notes_dir, git = { auto_commit = true } })
    commands.createNote(notes_dir, "floating", true)
    close_float({ close = function() end })

    assert(git_calls == 1, "Expected q to trigger git operations only once through BufWritePost")

    package.loaded["snacks"] = original_snacks
    handle_git:revert()
  end)

  it("tracks the last non-floating project note that was opened", function()
    local commands = require("notes.commands")
    local repo_dir = make_temp_dir("notes-last-note-repo")
    local project_notes_dir = make_temp_dir("notes-last-note-store")
    local original_cwd = vim.fn.getcwd()

    vim.fn.system({ "git", "init", repo_dir })
    vim.api.nvim_set_current_dir(repo_dir)
    plugin.setup({ projectNotesDir = project_notes_dir })

    commands.openProjectNote("first", false)
    vim.cmd("silent write")
    commands.openProjectNote("second", false)
    vim.cmd("silent write")
    commands.openLastNote(false)

    assert(
      vim.api.nvim_buf_get_name(0) == vim.fs.joinpath(project_notes_dir, "notes-last-note-repo", "second.md"),
      "Expected last note to be updated on normal opens"
    )

    vim.api.nvim_set_current_dir(original_cwd)
  end)

  it("rejects deleting files outside the configured note roots", function()
    local commands = require("notes.commands")
    local root_dir = make_temp_dir("notes-root-check")
    local notes_dir = vim.fs.joinpath(root_dir, "global")
    local outside_dir = vim.fs.joinpath(root_dir, "global-backup")
    local outside_file = vim.fs.joinpath(outside_dir, "todo.md")
    local notify = stub(vim, "notify")

    vim.fn.mkdir(notes_dir, "p")
    vim.fn.mkdir(outside_dir, "p")
    write_file(outside_file)

    plugin.setup({
      notesDir = notes_dir,
      projectNotesDir = vim.fs.joinpath(root_dir, "projects"),
      journalDir = vim.fs.joinpath(root_dir, "journal"),
    })

    vim.cmd("edit " .. vim.fn.fnameescape(outside_file))
    commands.deleteNote()

    -- selene: allow(incorrect_standard_library_use)
    assert.stub(notify).was_called_with("Current file is not a note", vim.log.levels.WARN)

    notify:revert()
  end)

  it("rejects renaming files outside the configured note roots", function()
    local commands = require("notes.commands")
    local root_dir = make_temp_dir("notes-rename-root-check")
    local notes_dir = vim.fs.joinpath(root_dir, "global")
    local outside_dir = vim.fs.joinpath(root_dir, "global-backup")
    local outside_file = vim.fs.joinpath(outside_dir, "todo.md")
    local notify = stub(vim, "notify")

    vim.fn.mkdir(notes_dir, "p")
    vim.fn.mkdir(outside_dir, "p")
    write_file(outside_file)

    plugin.setup({
      notesDir = notes_dir,
      projectNotesDir = vim.fs.joinpath(root_dir, "projects"),
      journalDir = vim.fs.joinpath(root_dir, "journal"),
    })

    vim.cmd("edit " .. vim.fn.fnameescape(outside_file))
    commands.renameNote("renamed")

    -- selene: allow(incorrect_standard_library_use)
    assert.stub(notify).was_called_with("Current file is not a note", vim.log.levels.WARN)

    notify:revert()
  end)

  it("keeps the git BufWritePost autocmd after renaming a note", function()
    local commands = require("notes.commands")
    local notes_dir = make_temp_dir("notes-rename-autocmd")

    plugin.setup({ notesDir = notes_dir, git = { auto_commit = true } })
    commands.createNote(notes_dir, "original", false)
    vim.cmd("silent write")
    commands.renameNote("renamed")

    local autocmds =
      vim.api.nvim_get_autocmds({ event = "BufWritePost", group = "NotesGit", buffer = vim.api.nvim_get_current_buf() })
    assert(
      vim.api.nvim_buf_get_name(0) == vim.fs.joinpath(notes_dir, "renamed.md"),
      "Expected renamed buffer to be current"
    )
    assert(#autocmds > 0, "Expected renamed note buffer to retain the git BufWritePost autocmd")
  end)
end)

describe("git integration", function()
  it("commits only the written note when unrelated changes are staged", function()
    local git_integration = require("notes.git")
    local repo_dir = make_temp_dir("notes-git-scope")
    local note_path = vim.fs.joinpath(repo_dir, "note.md")
    local unrelated_path = vim.fs.joinpath(repo_dir, "unrelated.txt")

    init_git_repo(repo_dir)
    write_file(note_path, { "initial" })
    git({ "add", "note.md" }, repo_dir)
    git({ "commit", "-m", "Initial note" }, repo_dir)

    write_file(note_path, { "updated" })
    write_file(unrelated_path, { "staged but unrelated" })
    git({ "add", "unrelated.txt" }, repo_dir)

    plugin.setup({
      notesDir = repo_dir,
      git = {
        auto_commit = true,
        auto_push = false,
        commit_message = "Update notes",
      },
    })

    assert(
      git_integration.handleGitOperations(note_path) == nil,
      "Expected handleGitOperations to complete without throwing"
    )

    local committed_files = git_lines({ "show", "--pretty=format:", "--name-only", "HEAD" }, repo_dir)
    local staged_files = git_lines({ "diff", "--cached", "--name-only" }, repo_dir)

    assert(vim.deep_equal(committed_files, { "note.md" }), "Expected auto-commit to include only the note")
    assert(vim.deep_equal(staged_files, { "unrelated.txt" }), "Expected unrelated staged changes to remain staged")
  end)

  it("does not override git commit signing config", function()
    local git_integration = require("notes.git")
    local repo_dir = make_temp_dir("notes-git-signing")
    local note_path = vim.fs.joinpath(repo_dir, "note.md")
    local original_system = vim.fn.system
    local commit_cmd

    init_git_repo(repo_dir)
    write_file(note_path, { "initial" })
    git({ "add", "note.md" }, repo_dir)
    git({ "commit", "-m", "Initial note" }, repo_dir)

    write_file(note_path, { "updated" })

    plugin.setup({
      notesDir = repo_dir,
      git = {
        auto_commit = true,
        auto_push = false,
        commit_message = "Update notes",
      },
    })

    local system = stub(vim.fn, "system", function(cmd)
      if type(cmd) == "table" and cmd[1] == "git" and cmd[2] == "-C" and cmd[3] == repo_dir and cmd[4] == "commit" then
        commit_cmd = vim.deepcopy(cmd)
      end
      return original_system(cmd)
    end)

    assert(
      git_integration.handleGitOperations(note_path) == nil,
      "Expected handleGitOperations to complete without throwing"
    )
    assert(commit_cmd ~= nil, "Expected auto-commit to invoke git commit")

    for _, arg in ipairs(commit_cmd) do
      assert(arg ~= "-c", "Expected auto-commit to respect git config without overriding commit settings")
      assert(arg ~= "commit.gpgsign=false", "Expected auto-commit to avoid disabling commit signing")
    end

    system:revert()
  end)
end)

describe("plugin commands", function()
  it("passes relative subdirectory paths to CreateNote", function()
    local created_commands = {}
    local command_options = {}
    local create_user_command = stub(vim.api, "nvim_create_user_command", function(name, callback, opts)
      created_commands[name] = callback
      command_options[name] = opts
    end)
    local create_note = stub(plugin, "createNote")

    dofile(vim.fs.joinpath(vim.fn.getcwd(), "plugin", "notes.lua"))
    created_commands.CreateNote({ args = "work/projects/roadmap" })

    -- selene: allow(incorrect_standard_library_use)
    assert.spy(create_note).was_called_with("work/projects/roadmap")
    assert(command_options.CreateNote.nargs == "*", "Expected CreateNote to accept paths containing spaces")

    create_note:revert()
    create_user_command:revert()
  end)

  it("parses ProjectNote names with spaces and trailing float", function()
    local created_commands = {}
    local create_user_command = stub(vim.api, "nvim_create_user_command", function(name, callback)
      created_commands[name] = callback
    end)
    local open_project_note = stub(plugin, "openProjectNote")

    dofile(vim.fs.joinpath(vim.fn.getcwd(), "plugin", "notes.lua"))
    created_commands.ProjectNote({ args = "weekly review float" })

    -- selene: allow(incorrect_standard_library_use)
    assert.spy(open_project_note).was_called_with("weekly review", true)

    open_project_note:revert()
    create_user_command:revert()
  end)
end)

describe("main module exports", function()
  it("exports deleteNote", function()
    assert(type(plugin.deleteNote) == "function", "Expected deleteNote main export")
  end)

  it("exports renameNote", function()
    assert(type(plugin.renameNote) == "function", "Expected renameNote main export")
  end)

  it("exports createNote", function()
    assert(type(plugin.createNote) == "function", "Expected createNote main export")
  end)

  it("exports findNote", function()
    assert(type(plugin.findNote) == "function", "Expected findNote main export")
  end)

  it("exports grepNote", function()
    assert(type(plugin.grepNote) == "function", "Expected grepNote main export")
  end)

  it("exports openJournal", function()
    assert(type(plugin.openJournal) == "function", "Expected openJournal main export")
  end)

  it("exports lastNote", function()
    assert(type(plugin.lastNote) == "function", "Expected lastNote main export")
  end)
end)
