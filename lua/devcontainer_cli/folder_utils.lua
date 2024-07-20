local M = {}

function M.get_directory_from_path(file_path)
  return file_path:match("(.*/)")
end

-- Get root folder
function M.get_root_folder()
  local workspace_folders = vim.lsp.buf.list_workspace_folders()
  local git_dir = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
  local root_dir = ""

  local cwd = M.get_directory_from_path(vim.api.nvim_buf_get_name(0))
  local cwd_devcontainer = cwd .. "/.devcontainer"
  if vim.fn.isdirectory(cwd_devcontainer) then
    print("root_folder [cwd_devcontainer]: " .. cwd)
    return cwd:gsub("\n", "")
  end

  if #workspace_folders > 0 then
    -- workspace_folders is calculated dinamically by the LSP client
    -- choose the longest path as root_dir
    for _, folder in ipairs(workspace_folders) do
      print("root_folder [lsp, workspace_folder]: " .. folder)
      if #folder > #root_dir then
        root_dir = folder
      end
    end
    -- choose the last value
    -- root_dir = workspace_folders[#workspace_folders]
  else
    print("root_folder [git]: " .. git_dir)
    if git_dir == "" then
      root_dir = vim.fn.getcwd()
    else
      root_dir = git_dir
    end
  end
  print("root_dir: " .. root_dir)
  return root_dir:gsub("\n", "")
end

function M.folder_exists(target_folder)
  local target_folder_absolut = M.get_root_folder() .. "/" .. target_folder
  print("Checking if folder exists:" .. target_folder_absolut)
  return (vim.fn.isdirectory(target_folder_absolut) == 1)
end

return M
