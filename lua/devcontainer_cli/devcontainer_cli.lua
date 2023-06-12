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

local function create_floating_terminal(command, opts)
	-- TODO: Adapt size dynamically based on the screen size of the user

	-- Set the size and position of the floating window
	local width = 160
	local height = 40
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create the floating window
	local buf = vim.api.nvim_create_buf(false, true)
	local win_id = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})

	-- Open terminal in the new window
	-- TODO: this part of the code should not be part of the create_floadting_window function, as it has a different responsability
	vim.fn.termopen(command, {
		-- TODO: saves the output logs in a file which can be checked anytime.
		-- TODO: Close the floating window when the terminal job exits
		-- Examle: vim.api.nvim_win_close(win_id, true)
		on_stdout = function(_, data, _)
			-- Scroll the terminal window to view new output
			vim.api.nvim_win_call(win_id, function()
				vim.cmd("normal! G")
			end)
		end,
		scrollback = 1000, -- Adjust the scrollback limit as needed
	})
	vim.api.nvim_set_current_buf(buf)
end

local function folder_exists(target_folder)
	return (vim.fn.isdirectory(vim.fn.getcwd() .. "/" .. target_folder) == 1)
end

function M.up(user_config)
	user_config = user_config or {}

	for option, value in pairs(user_config) do
		config[option] = value
	end

	if not folder_exists(config.devcontainer_folder) then
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
	create_floating_terminal(command, {})
end

function M.connect()
	-- Thanks to the autocommand executed after leaving the UI, after closing the
	-- neovim window the devcontainer will be automatically open in a new terminal
	define_autocommands()
	vim.cmd("wqa")
end

return M
-- return devconatiner_cli_plugin
