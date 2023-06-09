local M = {}

function M.create_floating_terminal(command, opts)
    -- TODO: Adapt size dynamically based on the screen size of the user
    local on_fail = opts.on_fail
        or function(exit_code)
            vim.notify(
                "The process running in the floating window has failed! exit_code: " .. exit_code,
                vim.log.levels.ERROR
            )
        end
    local on_success = opts.on_success
        or function(win_id)
            vim.notify("The process running in the floating window has succeeded!", vim.log.levels.INFO)
            vim.api.nvim_win_close(win_id, true)
        end
    -- Set the size and position of the floating window
    local width = 160
    local height = 40
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create the floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "single",
    })

    -- Open terminal in the new window
    -- TODO: this part of the code should not be part of the create_floadting_window funclltion, as it has a different responsability
    vim.fn.termopen(command, {
        on_exit = function(_, exit_code)
            -- TODO: saves the output logs in a file which can be checked anytime.
            if exit_code == 0 then
                on_success(win_id)
            else
                on_fail(exit_code)
            end
        end,
        on_stdout = function(_, data, _)
            -- Scroll the terminal window to view new output
            vim.api.nvim_win_call(win_id, function()
                vim.cmd("normal! G")
            end)
        end,
        scrollback = 1000, -- Adjust the scrollback limit as needed
    })
    vim.api.nvim_set_current_buf(buf)
end

return M
