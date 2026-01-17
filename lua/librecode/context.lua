local config = require("librecode.config")

local M = {}

function M.get()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1]

    local start = math.max(0, row - config.options.max_context_lines)
    local lines = vim.api.nvim_buf_get_lines(bufnr, start, row, false)
    return table.concat(lines, "\n")
end

return M
