local windows_utils = require("devcontainer_cli.windows_utils")
local folder_utils = require("devcontainer_cli.folder_utils")

local M = {}

local config = {
	devcontainer_folder = ".devcontainer/",
	nvim_plugin_folder = "~/.local/share/nvim/lazy/nvim-devcontainer-cli/",
}

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

function M.up(user_config)
	user_config = user_config or {}

	for option, value in pairs(user_config) do
		config[option] = value
	end

	if not folder_utils.folder_exists(config.devcontainer_folder) then
		print(
			"Devcontainer folder not available: "
				.. config.devcontainer_folder
				.. ". devconatiner_cli_plugin plugin cannot be used"
		)
		return
	else
		print("Devcontainer folder detected. Path: " .. config.devcontainer_folder)
	end

	local command = config.nvim_plugin_folder .. "/bin/spawn_devcontainer.sh true"
	windows_utils.create_floating_terminal(command, {
		on_success = function(win_id)
			vim.notify("A devcontainer has been successfully spawn by the nvim-devcontainer-cli!", vim.log.levels.INFO)
			vim.api.nvim_win_close(win_id, true)
		end,
		on_fail = function(exit_code)
			vim.notify("A devcontainer has failed to spawn! exit_code: " .. exit_code, vim.log.levels.ERROR)
		end,
	})
end

function M.connect()
	-- Thanks to the autocommand executed after leaving the UI, after closing the
	-- neovim window the devcontainer will be automatically open in a new terminal
	define_autocommands()
	vim.cmd("wqa")
end

return M
