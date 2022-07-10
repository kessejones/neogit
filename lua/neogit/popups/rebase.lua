local cli = require("neogit.lib.git.cli")
local popup = require("neogit.lib.popup")
local CommitSelectViewBuffer = require("neogit.buffers.commit_select_view")
local rebase = require("neogit.lib.git.rebase")
local status = require("neogit.status")
local branch = require("neogit.lib.git.branch")
local BranchSelectViewBuffer = require("neogit.buffers.branch_select_view")

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
    :action("i", "Interactive", function()
      local commits = rebase.commits()
      CommitSelectViewBuffer.new(commits, function(_view, selected)
        rebase.run_interactive(selected.oid)
        _view:close()
      end):open()
    end)
    :build()

  p:show()

  return p
end

return M
