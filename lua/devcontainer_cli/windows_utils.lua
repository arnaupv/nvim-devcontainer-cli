local M = {}

local function wrap_text(text, max_width)
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

function M.open_floating_window() -- content)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

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
    border = "single",
  })

    return win, buf
end

function M.send_text(text, buffer)
  local text = vim.split(wrap_text(text, 80), "\n")

  -- Set the content of the buffer
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, text)
end

-- local function close_window(win, buf)
--   vim.api.nvim_win_close(win, true)
--   vim.api.nvim_buf_delete(buf, {force = true})
-- end

-- local function handle_response(response, func, args, buf)
--   if response == "q" or response == "Q" then
--     print("Cancelling...")
--   else
--     fun(args, buf)
--   end
-- end

-- function M.prompt_and_run_command(output, func, args)
--   local content = {output .. "Press 'q' to exit or Enter to continue."}
--   local win, buf = open_floating_window(content)

--   vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<Cmd>lua close_window('..win..', '..buf..')<CR>', {noremap = true})
--   vim.api.nvim_buf_set_keymap(buf, 'n', 'Q', '<Cmd>lua close_window('..win..', '..buf..')<CR>', {noremap = true})
--   vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '<Cmd>lua handle_response("", '.. func..', '..args..', '..buf..')<CR>', {noremap = true})

-- end

return M
