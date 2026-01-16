local M = {}

M.defaults = {
	model = "qwen2.5-coder:1.5b",
	endpoint = "http://localhost:11434",
	keymap_accept = "<Tab>",
	max_context_lines = 40,
}

M.options = {}

function M.setup(user_config)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})
end

return M
