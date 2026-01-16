local config = require("librecode.config")
local completion = require("librecode.completion")

local M = {}

M.setup = function(user_config)
    config.setup(user_config)
    completion.setup()
end

return M
