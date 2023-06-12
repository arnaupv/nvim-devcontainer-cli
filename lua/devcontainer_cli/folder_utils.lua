local M = {}

function M.folder_exists(target_folder)
	return (vim.fn.isdirectory(vim.fn.getcwd() .. "/" .. target_folder) == 1)
end

return M
