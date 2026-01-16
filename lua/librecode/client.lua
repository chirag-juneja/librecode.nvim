local config = require("librecode.config")

local M = {}
M.latest_request_id = 0

local function handle_response(res, callback)
    if not res then
        return
    end
    local ok, decoded = pcall(vim.fn.json_decode, res)
    if not ok or not decoded then
        return
    end
    if decoded.response and decoded.response ~= "" then
        callback(decoded.response)
    end
end

function M.generate(prompt, callback)
    M.latest_request_id = M.latest_request_id + 1
    local current_id = M.latest_request_id
    local payload = vim.fn.json_encode({
        model = config.options.model,
        prompt = prompt,
        stream = false,
    })
    local cmd = {
        "curl",
        "-s",
        config.options.endpoint .. "/api/generate",
        "-H",
        "Content-Type: application/json",
        "-d",
        payload,
    }
    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                handle_response(table.concat(data, ""), callback)
            end
        end,
    })
end

return M
