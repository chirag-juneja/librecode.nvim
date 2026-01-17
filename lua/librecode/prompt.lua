local M = {}

function M.build(context)
    return [[
You are an expert programming assistant.

Task:
- Continue the **current line** of code only.
- Predict the most likely continuation from the cursor position.
- Do NOT add new lines.
- Return ONLY the code to be inserted.
- Do NOT repeat existing code.
- Do NOT include markdown or explanations.

Code context:
]] .. context .. "\n\nCompletion:"
end

return M
