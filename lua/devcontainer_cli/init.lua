local M = {}

local devcontainer_cli = require("devcontainer_cli.devcontainer_cli")

local configured = false

function M.setup()
  if configured then
    print("Already configured, skipping!")
    return
  end

  configured = true

  -- Docker
  vim.api.nvim_create_user_command("DevcontainerUp", function(opts)
    local env = opts.args or "pro"
    devcontainer_cli.up({ env = env, remove_existing_container = true })
  end, {
    nargs = "*",
    desc = "Up devcontainer using .devcontainer.json",
    complete = function(ArgLead, CmdLine, CursorPos)
      -- return completion candidates as a list-like table
      return { "dev", "pro" }
    end,
  })

  vim.api.nvim_create_user_command("DevcontainerConnect", function(_)
    devcontainer_cli.connect()
  end, {
    nargs = 0,
    desc = "Connect to devcontainer using .devcontainer.json",
  })
end

return M
