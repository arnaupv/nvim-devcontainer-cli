local ConfigModule = {}
local file_path = debug.getinfo(1).source:sub(2)
local default_config = {
  -- Folder where devcontainer tool looks for the devcontainer.json file
  devcontainer_folder = ".devcontainer/",
  
  -- Folder where the nvim-devcontainer-cli is installed
  nvim_plugin_folder = file_path:gsub("init.lua", "") .. "../../../",
  -- Remove existing container each time DevcontainerUp is executed
  -- If set to True [default_value] it can take extra time as you force to start from scratch
  remove_existing_container = true,
  -- dependencies that have to be installed in the devcontainer (remoteUser = root)
  setup_environment_repo = "https://github.com/arnaupv/setup-environment",
  -- directory for the setup environment
  setup_environment_directory = "setup_dotfiles",
  -- command that's executed for installed the dependencies from the setup_environment_repo
  setup_environment_install_command = "./install.sh -p nvim zsh stow --dotfiles",

  -- nvim_dotfiles that will be installed inside the docker devcontainer through the devcontainer cli.
  nvim_dotfiles_repo = "https://github.com/LazyVim/starter",
  -- branch to use for the nvim_dotfiles
  nvim_dotfiles_branch = "main",
  -- directory where to put the nvim_dotfiles
  nvim_dotfiles_directory = "nvim_dotfiles",
  -- nvim_dotfiles_install is the command that needs to be executed to install the dotfiles (it can be any bash command)
  nvim_dotfiles_install_command = "mv ~/dotfiles ~/.config/nvim",
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
