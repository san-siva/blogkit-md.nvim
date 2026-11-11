local registry = require 'blogkit-md.registry'

local M = {}

-- Oldest CLI release that supports --exclude.
local MIN_CLI_VERSION = '0.1.61'
local CLI_PACKAGE = '@san-siva/blogkit-md-cli'

local function parse_version(v)
	local a, b, c = tostring(v):match('^(%d+)%.(%d+)%.(%d+)')
	if not a then
		return nil
	end
	return { tonumber(a), tonumber(b), tonumber(c) }
end

local function version_lt(a, b)
	for i = 1, 3 do
		if a[i] ~= b[i] then
			return a[i] < b[i]
		end
	end
	return false
end

-- Version of the installed CLI, read from the package.json next to its bin/
-- directory (the executable resolves to <package>/bin/blogkit-md).
local function installed_version()
	local exe = vim.fn.exepath('blogkit-md')
	if exe == '' then
		return nil
	end
	local pkg = vim.fn.fnamemodify(vim.fn.resolve(exe), ':h:h') .. '/package.json'
	local ok, lines = pcall(vim.fn.readfile, pkg)
	if not ok then
		return nil
	end
	local decoded, data = pcall(vim.json.decode, table.concat(lines, '\n'))
	if not decoded or type(data) ~= 'table' then
		return nil
	end
	return parse_version(data.version)
end

-- Start a background preview for the given file or directory path. The CLI
-- opens the browser itself and reuses any existing server for the same path,
-- so this is safe to call repeatedly.
function M.start(path, exclude)
	local cmd = { 'blogkit-md', path }
	if vim.fn.isdirectory(path) == 1 and exclude and #exclude > 0 then
		table.insert(cmd, '--exclude=' .. table.concat(exclude, ','))
	end

	local id = vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code ~= 0 then
				vim.notify('BlogkitMd: blogkit-md exited with code ' .. code, vim.log.levels.WARN)
			end
		end,
	})

	if id <= 0 then
		vim.notify('BlogkitMd: failed to start blogkit-md.', vim.log.levels.ERROR)
		return
	end

	registry.add(path)
	vim.notify('BlogkitMd: preview started for ' .. path, vim.log.levels.INFO)
end

-- Stop the preview serving the given path. Runs synchronously so it completes
-- even when called on Neovim exit.
function M.stop(path)
	vim.fn.system({ 'blogkit-md', '-s', path })
	registry.remove(path)
end

local function install(action, callback)
	vim.notify('BlogkitMd: ' .. action .. ' blogkit-md-cli via npm...', vim.log.levels.INFO)

	vim.fn.jobstart({ 'npm', 'install', '-g', CLI_PACKAGE .. '@latest' }, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify('BlogkitMd: installed successfully.', vim.log.levels.INFO)
				callback()
			else
				vim.notify(
					'BlogkitMd: installation failed. Install manually: npm install -g ' .. CLI_PACKAGE,
					vim.log.levels.ERROR
				)
			end
		end,
	})
end

-- Make sure a CLI new enough for this plugin is installed, installing or
-- upgrading it when needed.
function M.ensure_cli(callback)
	if vim.fn.executable('blogkit-md') ~= 1 then
		return install('not found. Installing', callback)
	end

	local have = installed_version()
	if have and version_lt(have, parse_version(MIN_CLI_VERSION)) then
		return install('older than ' .. MIN_CLI_VERSION .. '. Upgrading', callback)
	end

	callback()
end

return M
