local Buffer = require("neogit.lib.buffer")
local config = require("neogit.config")
local input = require("neogit.lib.input")

local M = {}

function M.new(content, filename, on_close)
  local instance = {
    content = content,
    filename = filename,
    on_close = on_close,
    buffer = nil
  }

  setmetatable(instance, { __index = M })

  return instance
end

function M:open()
  local written = false
  self.buffer = Buffer.create {
    name = self.filename,
    filetype = "NeogitCommitMessage",
    buftype = "",
    kind = config.values.commit_popup.kind,
    modifiable = true,
    readonly = false,
    autocmds = {
      ["BufWritePost"] = function()
        written = true
      end,
      ["BufUnload"] = function()
        self.on_close()
        if written then
          if config.values.disable_commit_confirmation or
            input.get_confirmation("Are you sure you want to commit?") then
            vim.cmd [[
              silent g/^#/d
              silent w!
            ]]
          end
        end
      end,
    },
    mappings = {
      n = {
        ["q"] = function(buffer)
          buffer:close(true)
        end
      }
    },
    initialize = function(buffer)
      buffer:set_lines(0, -1, false, self.content)
      if not config.values.disable_insert_on_commit then
        vim.cmd(":startinsert")
      end

      -- NOTE: This avoids the user having to force to save the contents of the buffer.
      vim.cmd[[silent w!]]
    end
  }
end

return M
