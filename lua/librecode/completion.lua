local client = require("librecode.client")
local context = require("librecode.context")
local prompt = require("librecode.prompt")
local config = require("librecode.config")
local utils = require("librecode.utils")

local M = {}

M.ghost = {
	text = "",
	ns = vim.api.nvim_create_namespace("librecode"),
	extmark_id = {},
}

function M.show(text)
	if not text or text == "" then
		return
	end

	text = text:gsub("^```%w*\n", "") -- remove ```lua or ```python
	text = text:gsub("```$", "")
	M.clear()
	local width = 0
	local lines = vim.split(text, "\n", { plain = true })
	for _, line in ipairs(lines) do
		width = math.max(width, #line)
	end
	local height = #lines

	-- Create buffer for floating window
	M.buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)

	-- Floating window options
	local opts = {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
	}

	M.win = vim.api.nvim_open_win(M.buf, false, opts)
end

function M.accept() end

function M.clear()
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_win_close(M.win, true)
	end
	M.win = nil
	M.buf = nil
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
	vim.keymap.set("i", "ll", function()
		M.suggestion()
	end, { noremap = true, silent = true })

	vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI", "InsertCharPre", "InsertLeave" }, {
		callback = function()
			vim.schedule(M.clear)
		end,
	})

	-- vim.api.nvim_create_autocmd("TextChangedI", {
	--     callback = M.suggestion,
	-- })
	-- vim.keymap.set("i", "<C-Tab>", function()
	-- M.accept()
	-- end, { noremap = true, silent = true })
end

return M
