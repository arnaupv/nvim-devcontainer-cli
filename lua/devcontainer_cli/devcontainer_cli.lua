local config = require("devcontainer_cli.config")
local folder_utils = require("devcontainer_cli.folder_utils")
local devcontainer_utils = require("devcontainer_cli.devcontainer_utils")

local M = {}

local function define_autocommands()
  local au_id = vim.api.nvim_create_augroup("devcontainer.docker.terminal", {})
  vim.api.nvim_create_autocmd("UILeave", {
    group = au_id,
    callback = function()
      -- It connects with the Devcontainer just after quiting neovim.
      -- TODO: checks that the devcontainer is not already connected
      -- TODO: checks that there is a devcontainer running
      vim.schedule(function()
        local command = config.nvim_plugin_folder .. "/bin/connect_to_devcontainer.sh"
        vim.fn.jobstart(command, { detach = true })
      end)
    end,
  })
end

function M.up()
  -- bringup the devcontainer
  devcontainer_parent = folder_utils.get_root(config.toplevel)
  if devcontainer_parent == nil then
    prev_win = vim.api.nvim_get_current_win()
    vim.notify(
      "Devcontainer folder not available. devconatiner_cli_plugin plugin cannot be used",
        vim.log.levels.ERROR
    )
    return
  end

  devcontainer_utils.bringup(devcontainer_parent)
end

function M.connect()
  -- Thanks to the autocommand executed after leaving the UI, after closing the
  -- neovim window the devcontainer will be automatically open in a new terminal
  define_autocommands()
  vim.cmd("wqa")
end

return M
