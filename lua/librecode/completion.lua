local client = require("librecode.client")
local context = require("librecode.context")
local prompt = require("librecode.prompt")
local config = require("librecode.config")
local utils = require("librecode.utils")

local M = {}

M.ghost = {
    text = "",
    ns = vim.api.nvim_create_namespace("librecode_inline"),
    extmark_id = nil,
}

function M.show(text)
    if not text or text == "" then
        return
    end

    -- Remove markdown fences
    text = text:gsub("^```%w*\n?", "")
    text = text:gsub("```$", "")

    -- Keep first line and remove leading spaces
    text = text:gsub("\n.*", "")
    text = text:gsub("^%s+", "")
    if text:match("^%s*$") then
        return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local win_width = vim.api.nvim_win_get_width(0)

    if col + #text >= win_width - 1 then
        return
    end
    M.clear()

    M.ghost.text = text
    M.ghost.extmark_id = vim.api.nvim_buf_set_extmark(0, M.ghost.ns, row - 1, col, {
        virt_text = { { text, "Comment" } },
        virt_text_pos = "overlay",
        hl_mode = "combine",
    })
end

function M.accept()
    if not M.ghost.text or M.ghost.text == "" then
        return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]

    local new_line = M.ghost.text
    -- Insert newline + predicted line
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, #line, { new_line })

    -- Move cursor to end of inserted line
    vim.api.nvim_win_set_cursor(0, { row, col + #new_line })

    M.clear()
end

function M.clear()
    if M.ghost.extmark_id then
        pcall(vim.api.nvim_buf_del_extmark, 0, M.ghost.ns, M.ghost.extmark_id)
    end
    M.ghost.extmark_id = nil
    M.ghost.text = ""
end

function M.get_completion()
    local current_prompt = prompt.build(context.get())
    client.generate(current_prompt, function(completion)
        if completion ~= "" then
            M.show(completion)
        else
            M.clear()
        end
    end)
end

function M.suggestion()
    M.clear()
    M.debounce_completion()
end

function M.setup()
    M.debounce_completion = utils.debounce(M.get_completion, 300)

    vim.keymap.set("n", "<leader>l", function()
        M.suggestion()
    end, { noremap = true, silent = true })

    vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI", "InsertCharPre", "InsertLeave", "CursorMoved" }, {
        callback = function()
            vim.schedule(M.clear)
        end,
    })

    vim.api.nvim_create_autocmd("TextChangedI", {
        callback = M.suggestion,
    })
    vim.keymap.set("i", "<C-l>", function()
        M.accept()
    end, { noremap = true, silent = true })
end

return M
