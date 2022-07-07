local cli = require("neogit.lib.git.cli")
local branch = require("neogit.lib.git.branch")
local popup = require("neogit.lib.popup")
local BranchSelectViewBuffer = require("neogit.buffers.branch_select_view")
local status = require("neogit.status")

local M = {}

local function format_branches(list)
  local branches = {}
  for _, name in ipairs(list) do
    local name_formatted = name:match("^remotes/(.*)") or name
    if not name_formatted:match("^(.*)/HEAD") then
      table.insert(branches, name_formatted)
    end
  end
  return branches
end

function M.create()
  local p = popup.builder()
    :name("NeogitRebasePopup")
    :action("p", "Rebase onto master", function()
      cli.rebase.args("master").call_sync()
    end)
    :action("e", "Rebase onto elsewhere", function()
      local branches = format_branches(branch.get_all_branches())
      BranchSelectViewBuffer.new(branches, function(selected_branch)
        if selected_branch == "" then
          return
        end

        cli.rebase.args(selected_branch).show_popup(true).call_sync()
        status.dispatch_refresh(true)
      end):open()
    end)
    :build()

  p:show()

  return p
end

return M
