local M = {}

local BASE_PORT = 3001
local registry = {} -- bufpath -> { id, port }

function M.get(bufpath)
	return registry[bufpath]
end

function M.set(bufpath, id, port)
	registry[bufpath] = { id = id, port = port }
end

function M.remove(bufpath)
	registry[bufpath] = nil
end

function M.is_empty()
	return next(registry) == nil
end

function M.each(fn)
	for bufpath, job in pairs(registry) do
		fn(bufpath, job)
	end
end

local function is_port_in_use(port)
	return vim.fn.system('lsof -ti :' .. port .. ' 2>/dev/null') ~= ''
end

function M.next_port()
	local used = {}
	for _, job in pairs(registry) do
		used[job.port] = true
	end
	local port = BASE_PORT
	while used[port] or is_port_in_use(port) do
		port = port + 1
	end
	return port
end

return M
