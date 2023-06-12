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
	vim.api.nvim_create_user_command("DevcontainerUp", function(_)
		devcontainer_cli.up()
	end, {
		nargs = 0,
		desc = "Up devcontainer using .devcontainer.json",
	})

	vim.api.nvim_create_user_command("DevcontainerConnect", function(_)
		devcontainer_cli.connect()
	end, {
		nargs = 0,
		desc = "Connect to devcontainer using .devcontainer.json",
	})
end

return M
