local M = {}

-- Get root folder where the git repo is located
function M.get_git_root_folder()
  local root_dir = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
  return root_dir:gsub("\n", "")
end

function M.folder_exists(target_folder)
  return (vim.fn.isdirectory(M.get_git_root_folder() .. "/" .. target_folder) == 1)
end

return M
