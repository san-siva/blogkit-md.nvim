local preview = require 'blogkit-md.preview'
local registry = require 'blogkit-md.registry'

local M = {}

-- Defaults; `exclude` is forwarded to the CLI as --exclude for directory
-- previews (names/globs matched against any path segment, e.g. 'node_modules').
M.config = { exclude = { 'node_modules' } }

function M.setup(opts)
	M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

-- Preview the current buffer's markdown file.
function M.preview_file()
	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == '' then
		vim.notify('BlogkitMd: current buffer has no file path.', vim.log.levels.ERROR)
		return
	end

	if not bufpath:match('%.md$') then
		vim.notify('BlogkitMd: only markdown files are supported.', vim.log.levels.ERROR)
		return
	end

	preview.ensure_cli(function()
		preview.start(bufpath)
	end)
end

-- Preview the working directory of the current Neovim session. `opts.exclude`
-- (a list of patterns) overrides the configured excludes for this call; an
-- empty list excludes nothing.
function M.preview_dir(opts)
	opts = opts or {}
	local dir = vim.fn.getcwd()
	local exclude = opts.exclude or M.config.exclude
	preview.ensure_cli(function()
		preview.start(dir, exclude)
	end)
end

-- Stop every preview started this session, one path at a time.
function M.stop(opts)
	opts = opts or {}

	if registry.is_empty() then
		if not opts.quiet then
			vim.notify('BlogkitMd: no previews running.', vim.log.levels.WARN)
		end
		return
	end

	for _, path in ipairs(registry.list()) do
		preview.stop(path)
	end

	if not opts.quiet then
		vim.notify('BlogkitMd: all previews stopped.', vim.log.levels.INFO)
	end
end

return M
