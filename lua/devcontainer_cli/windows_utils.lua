local M = {}

function M.wrap_text(text, max_width)
  local wrapped_lines = {}
  for line in text:gmatch("[^\n]+") do
    local current_line = ""
    for word in line:gmatch("%S+") do
      if #current_line + #word <= max_width then
        current_line = current_line .. word .. " "
      else
        table.insert(wrapped_lines, current_line)
        current_line = word .. " "
      end
    end
    table.insert(wrapped_lines, current_line)
  end
  return table.concat(wrapped_lines, "\n")
end

function M.open_floating_window() 
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<CMD>close<CR>', {}) 
  vim.api.nvim_buf_set_keymap(buf, 'n', '<esc>', '<CMD>close<CR>', {})

  local width = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
  local height = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))

  local row = math.ceil(vim.o.lines - height) * 0.5 - 1
  local col = math.ceil(vim.o.columns - width) * 0.5 - 1

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = "devcontainer-cli",
    title_pos = center,
    -- noautocommand = false,
  })

  return win, buf
end

function M.send_text(text, buffer)
  local text = vim.split(wrap_text(text, 80), "\n")

  -- Set the content of the buffer
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, text)
end

return M
