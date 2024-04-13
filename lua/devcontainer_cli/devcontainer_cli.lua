local config = require("devcontainer_cli.config")
local windows_utils = require("devcontainer_cli.windows_utils")
local folder_utils = require("devcontainer_cli.folder_utils")

local M = {}

DEVCONTAINER_BUFFER = nil
DEVCONTAINER_LOADED = false
vim.g.devcontainer_opened = 0
local prev_win = -1
local win = -1
local buffer = -1

local function define_autocommands()
  local au_id = vim.api.nvim_open_augroup("devcontainer.docker.terminal", {})
  vim.api.nvim_open_autocmd("UILeave", {
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

local on_fail = function(exit_code)
  vim.notify(
      "Devcontainer process has failed! exit_code: " .. exit_code,
      vim.log.levels.ERROR
  )

  DEVCONTAINER_BUFFER = nil
  DEVCONTAINER_LOADED = false
  vim.g.devcontainer_opened = 0
  vim.cmd("silent! :checktime")
end

local on_success = function()
    vim.notify("Devcontainer process succeeded!", vim.log.levels.INFO)
    -- vim.api.nvim_win_close(win, true)
end

--- on_exit callback function to delete the open buffer when devcontainer exits in a neovim terminal
local function on_exit(job_id, code, event)
  if code == 0 then
    on_success()
    return
  end

  -- if vim.api.nvim_win_is_valid(prev_win) then
  --   vim.api.nvim_win_close(win, true)
  --   vim.api.nvim_set_current_win(prev_win)
  --   prev_win = -1
  --   if vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_is_loaded(buffer) then
  --     vim.api.nvim_buf_delete(buffer, { force = true })
  --   end
  --   buffer = -1
  --   win = -1
  -- end

  on_fail(code)
end

--- Call devcontainer
local function exec_command(cmd)
  if DEVCONTAINER_LOADED == false then
    -- ensure that the buffer is closed on exit
    vim.g.devcontainer_opened = 1
    vim.fn.termopen(
      cmd, 
      { 
        on_exit = on_exit,
        on_stdout = function(_, data, _)
          vim .api.nvim_win_call(
            win,
            function()
              vim.cmd("normal! G")
            end
          ) 
        end,
      }
    )
    vim.api.nvim_set_current_buf(buffer)
  end
end

function M.up()
  if not folder_utils.folder_exists(config.devcontainer_folder) then
    prev_win = vim.api.nvim_get_current_win()
    vim.notify(
      "Devcontainer folder not available: "
        .. config.devcontainer_folder
        .. ". devconatiner_cli_plugin plugin cannot be used",
        vim.log.levels.ERROR
    )
    return
  end

  local command = config.nvim_plugin_folder .. "/bin/spawn_devcontainer.sh"

  if config.remove_existing_container then
    command = command .. " --remove-existing-container"
  end
  command = command .. " --root_directory " .. folder_utils.get_root_folder()
  command = command .. " --setup-environment-repo " .. config.setup_environment_repo
  command = command .. " --setup-environment-dir " .. '"' .. config.setup_environment_directory .. '"'
  command = command .. " --setup-environment-install-command " .. '"' .. config.setup_environment_install_command .. '"'
  command = command .. " --nvim-dotfiles-repo " .. '"' .. config.nvim_dotfiles_repo .. '"'
  command = command .. " --nvim-dotfiles-branch " .. '"' .. config.nvim_dotfiles_branch .. '"'
  command = command .. " --nvim-dotfiles-directory " .. '"' .. config.nvim_dotfiles_directory .. '"'
  command = command .. " --nvim-dotfiles-install-command " .. '"' .. config.nvim_dotfiles_install_command .. '"'

  continue = vim.fn.input(
    windows_utils.wrap_text(
      "Devcontainer folder detected. Path: " .. config.devcontainer_folder .. "\n" ..
        "Spawning devcontainer with command: " .. command .. "\n\n" ..
        "Press q to cancel or <enter> to continue\n",
      80
    )
  )
  if continue == "q" or continue == "Q" then
    vim.notify(
      "\nUser cancelled bringing up devcontainer"
    )
  else
    win, buffer = windows_utils.open_floating_window()
    exec_command(command)
  end
end

function M.connect()
  -- Thanks to the autocommand executed after leaving the UI, after closing the
  -- neovim window the devcontainer will be automatically open in a new terminal
  define_autocommands()
  vim.cmd("wqa")
end

return M
