local plugin = require("notes")

describe("setup", function()
  it("validates default notes path", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.notesDir == os.getenv("HOME") .. "/notes/global")
  end)

  it("validates default project notes path", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.projectNotesDir == os.getenv("HOME") .. "/notes/project")
  end)

  it("validates custom notes path", function()
    plugin.setup({ notesDir = "/test/dir" })
    local config = require("notes.config").config
    assert(config.notesDir == "/test/dir")
  end)

  it("validates custom project notes path", function()
    plugin.setup({ projectNotesDir = "/test/dir" })
    local config = require("notes.config").config
    assert(config.projectNotesDir == "/test/dir")
  end)
end)
