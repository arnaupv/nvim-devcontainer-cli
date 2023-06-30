local M = {}

local devcontainer_cli = require("devcontainer_cli.devcontainer_cli")
local config = require("devcontainer_cli.config")
local configured = false

function M.setup(opts)
  config.setup(opts)

  if configured then
    print("Already configured, skipping!")
    return
  end

  configured = true

  -- Docker
  vim.api.nvim_create_user_command("DevcontainerUp", function(opts)
    -- Try to use opts.args and if empty use "pro"
    devcontainer_cli.up()
  end, {
    nargs = 0,
    desc = "Up devcontainer using .devcontainer/devcontainer.json",
  })

  vim.api.nvim_create_user_command("DevcontainerConnect", function(_)
    devcontainer_cli.connect()
  end, {
    nargs = 0,
    desc = "Connect to devcontainer using .devcontainer.json",
  })
end

return M
