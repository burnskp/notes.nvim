local plugin = require("notes")

describe("setup", function()
  it("validate default notes path", function()
    plugin.setup()
    local config = require("notes.config").config
    assert(config.notesDir == os.getenv("HOME") .. "/notes")
  end)

  it("validates custom notes path", function()
    plugin.setup({ notesDir = "/test/dir" })
    local config = require("notes.config").config
    assert(config.notesDir == "/test/dir")
  end)
end)
