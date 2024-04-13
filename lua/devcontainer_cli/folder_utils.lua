local M = {}

-- return true if directory exists
local function directory_exists(target_folder)
  return (vim.fn.isdirectory(target_folder) == 1)
end

-- return directory if a devcontainer exists within it or nil otherwise
local function get_devcontainer_parent(directory)
  local devcontainer_directory = directory .. '/.devcontainer'

  if directory_exists(devcontainer_directory) then
    return directory
  end

  return nil 
end

-- return the devcontainer directory closes to the root directory
-- or the first if toplevel is true
local function get_root_directory(directory, toplevel)
  local parent_directory = vim.fn.fnamemodify(directory, ':h')
  local devcontainer_parent =  get_devcontainer_parent(directory)
  
  -- Base case: If we've reached the root directory
  if parent_directory == directory then
    return devcontainer_parent
  end

  if not toplevel and devcontainer_parent ~= nil then
    return devcontainer_parent
  end

  local upper_devcontainer_directory = get_root_directory(parent_directory, toplevel)
  -- no devcontainer higher up so return what was found here
  if upper_devcontainer_directory == nil then
    return devcontainer_parent
  end

  -- return the highest level devcontainer
  return upper_devcontainer_directory
end

-- find the .devcontainer directory closes to the root 
-- upward from the current directory
function M.get_root(toplevel)
  local current_directory = vim.fn.getcwd()
  return get_root_directory(current_directory, toplevel)
end

return M
