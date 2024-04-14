local config = require("devcontainer_cli.config")
local windows_utils = require("devcontainer_cli.windows_utils")
local folder_utils = require("devcontainer_cli.folder_utils")

local M = {}

local prev_win = -1
local win = -1
local buffer = -1

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

-- window the created window detaches set things back to -1
local on_detach = function()
  prev_win = -1
  win = -1
  buffer = -1
end

local on_fail = function(exit_code)
  vim.notify(
      "Devcontainer process has failed! exit_code: " .. exit_code,
      vim.log.levels.ERROR
  )

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

  on_fail(code)
end

--- Call devcontainer
local function exec_command(cmd)
  -- ensure that the buffer is closed on exit
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

function M.up()
  devcontainer_parent = folder_utils.get_root(config.toplevel)
  if devcontainer_parent == nil then
    prev_win = vim.api.nvim_get_current_win()
    vim.notify(
      "Devcontainer folder not available. devconatiner_cli_plugin plugin cannot be used",
        vim.log.levels.ERROR
    )
    return
  end

  local command = config.nvim_plugin_folder .. "/bin/spawn_devcontainer.sh"

  if config.remove_existing_container then
    command = command .. " --remove-existing-container"
  end
  command = command .. " --root_directory " .. devcontainer_parent
  command = command .. " --setup-environment-repo " .. config.setup_environment_repo
  command = command .. " --setup-environment-dir " .. '"' .. config.setup_environment_directory .. '"'
  command = command .. " --setup-environment-install-command " .. '"' .. config.setup_environment_install_command .. '"'
  command = command .. " --nvim-dotfiles-repo " .. '"' .. config.nvim_dotfiles_repo .. '"'
  command = command .. " --nvim-dotfiles-branch " .. '"' .. config.nvim_dotfiles_branch .. '"'
  command = command .. " --nvim-dotfiles-directory " .. '"' .. config.nvim_dotfiles_directory .. '"'
  command = command .. " --nvim-dotfiles-install-command " .. '"' .. config.nvim_dotfiles_install_command .. '"'

  local message = windows_utils.wrap_text(
      "Devcontainer folder detected. Path: " .. devcontainer_parent .. "\n" ..
      "Spawning devcontainer with command: " .. command,
      80
  )

  if config.interactive then
    vim.ui.input(
      message .. "\n\n" ..
          "Press q to cancel or any other key to continue\n",
      function(input)
        if (input == "q" or input == "Q") then
          vim.notify(
            "\nUser cancelled bringing up devcontainer"
          )
        else
          win, buffer = windows_utils.open_floating_window()
          exec_command(command)
        end
      end
    )
  else
    vim.notify(message)
    win, buffer = windows_utils.open_floating_window(on_detach)
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
