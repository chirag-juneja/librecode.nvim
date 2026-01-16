local M = {}

function M.debounce(fn, delay)
    local timer = vim.loop.new_timer()
    local last_args = nil

    local function run()
        if not last_args then
            return
        end
        vim.schedule(function ()
            fn(unpack(last_args))
        end)
    end

    local function trigger(...)
        last_args = {...}
        timer:stop()
        timer:start(delay,0,run)
    end
    return trigger

end

return M
