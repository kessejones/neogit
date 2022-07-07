local fn = vim.fn
local fmt = string.format

local M = {}

function M.client()
  local nvim_server = vim.env.NVIM

  local target = fn.fnamemodify(fn.argv()[1], ':p')
  local ch = fn.sockconnect('pipe', nvim_server, { rpc = true })

  local client = fn.serverstart()
  local lua_cmd = fmt('lua require("neogit.remote").editor("%s", "%s")', target, client)

  vim.rpcrequest(ch, 'nvim_command', lua_cmd)
end

function M.editor(target, client)
  local editor = require('neogit.editor')

  local ch = fn.sockconnect('pipe', client, { rpc = true })

  local function send_client_quit()
    vim.rpcnotify(ch, 'nvim_command', 'qall')
    fn.chanclose(ch)
  end

  if target:find('git%-rebase%-todo$') then
    editor.rebase_editor(target, send_client_quit)
  elseif target:find('COMMIT_EDITMSG$') then
    editor.commit_editor(target, send_client_quit)
  else
    send_client_quit()
  end
end

return M
