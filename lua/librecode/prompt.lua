local M = {}

function M.build(context)
	return [[
You are an expert programming assistant.

Task:
- Continue the code below.
- Predict the most likely next code.
- Return ONLY the code to be inserted.
- Do NOT explain.
- Do NOT repeat existing lines.
- Do NOT include markdown.

Code:
]] .. context .. "\n\nCompletion:"
end

return M
