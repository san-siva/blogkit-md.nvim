local preview = require 'blogkit-md.preview'
local registry = require 'blogkit-md.registry'

local M = {}

function M.setup(opts)
	M.config = opts or {}
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

-- Preview the working directory of the current Neovim session.
function M.preview_dir()
	local dir = vim.fn.getcwd()
	preview.ensure_cli(function()
		preview.start(dir)
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
