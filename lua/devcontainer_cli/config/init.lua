local ConfigModule = {}

local default_config = {
  --[[
    "dev":
    nvim-devcontainer-cli plugin mounted in the devcontainer. This is only needed
    if you are developing the plugin itself, as the changes inside the container
    wil be reflected in the host.

    "pro": [default_value]
    nvim-devcontainer-cli plugin not mount in the devcontainer.
  --]]
  env = "pro", -- Options: pro/dev
  -- Folder where devcontainer tool looks for the devcontainer.json file
  devcontainer_folder = ".devcontainer/",
  -- Folder where the nvim-devcontainer-cli is installed
  nvim_plugin_folder = "~/.local/share/nvim/lazy/nvim-devcontainer-cli/",
  -- Remove existing container each time DevcontainerUp is executed
  -- If set to True [default_value] it can take extra time as you force to start from scratch
  remove_existing_container = true,
}

local options

function ConfigModule.setup(opts)
  opts = vim.tbl_deep_extend("force", default_config, opts or {})
  options = opts
end

return setmetatable(ConfigModule, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(default_config)[key]
    end
    return options[key]
  end,
})
