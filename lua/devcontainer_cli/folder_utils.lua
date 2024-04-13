local M = {}

-- Get root folder
function M.get_root_folder()
  local workspace_folders = vim.lsp.buf.list_workspace_folders()
  local git_dir = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
  local root_dir = ""

  if #workspace_folders > 0 then
    -- workspace_folders is calculated dinamically by the LSP client
    -- choose the longest path as root_dir
    for _, folder in ipairs(workspace_folders) do
      if #folder > #root_dir then
        root_dir = folder
      end
    end
    -- choose the last value
    -- root_dir = workspace_folders[#workspace_folders]
  else
    if git_dir == "" then
      root_dir = vim.fn.getcwd()
    else
      root_dir = git_dir
    end
  end
  return root_dir:gsub("\n", "")
end

function M.folder_exists(target_folder)
  return (vim.fn.isdirectory(M.get_root_folder() .. "/" .. target_folder) == 1)
end

return M
