local devconatiner_cli_plugin = {}

local function get_time()
	return vim.fn.reltimefloat(vim.fn.reltime()) * 1000
end

local last_time = get_time()

local config = {
	devcontainer_folder = ".devcontainer/",
}
-- Create a function that given as input the target folder, it returns True if a folder exists and false if not (include folders only in the root of the project)
local function folder_exists(target_folder)
	return vim.fn.isdirectory(target_folder .. config.devcontainer_folder) == 1
end

function devconatiner_cli_plugin.setup(user_config)
	user_config = user_config or {}

	for option, value in pairs(user_config) do
		config[option] = value
	end

	if not folder_exists(config.devcontainer_folder) then
		print("Devcontainer folder not available. devconatiner_cli_plugin plugin cannot be used")
		return
	else
		-- print that the devcontainer folder has been detected including the last_time variable
		print("Devcontainer folder detected. Last time: " .. last_time)
	end
end

return devconatiner_cli_plugin
