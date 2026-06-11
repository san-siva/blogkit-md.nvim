local M = {}

-- Set of paths (files or directories) we have started a preview for this
-- session. The blogkit-md CLI manages the background servers itself; we only
-- need to remember which paths we asked it to serve so we can stop them later
-- with `blogkit-md -s <path>` without relying on `blogkit-md -l`.
local paths = {}

function M.add(path)
	paths[path] = true
end

function M.remove(path)
	paths[path] = nil
end

function M.is_empty()
	return next(paths) == nil
end

function M.list()
	local out = {}
	for path in pairs(paths) do
		out[#out + 1] = path
	end
	return out
end

return M
