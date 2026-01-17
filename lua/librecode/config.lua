local M = {}

M.defaults = {
    model = "gemma3:4b",
    endpoint = "http://localhost:11434",
    keymap_accept = "<Tab>",
    max_context_lines = 80,
}

M.options = {}

function M.setup(user_config)
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})
end

return M
