local jobs = require 'blogkit-md.jobs'
local preview = require 'blogkit-md.preview'

local M = {}

function M.setup(opts)
	M.config = opts or {}
end

function M.start()
	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == '' then
		vim.notify('BlogkitMd: current buffer has no file path.', vim.log.levels.ERROR)
		return
	end

	local job = jobs.get(bufpath)
	if job then
		vim.notify(
			'BlogkitMd: preview already running for ' .. vim.fn.fnamemodify(bufpath, ':t') .. ' on port ' .. job.port,
			vim.log.levels.WARN
		)
		preview.open_browser(job.port)
		return
	end

	preview.ensure_cli(function()
		preview.launch(bufpath)
	end)
end

function M.stop()
	local bufpath = vim.api.nvim_buf_get_name(0)
	local job = jobs.get(bufpath)

	if not job then
		vim.notify('BlogkitMd: no preview running for this buffer.', vim.log.levels.WARN)
		return
	end

	vim.fn.jobstop(job.id)
	jobs.remove(bufpath)
	vim.notify('BlogkitMd: preview stopped for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.INFO)
end

function M.stop_all()
	if jobs.is_empty() then
		vim.notify('BlogkitMd: no previews running.', vim.log.levels.WARN)
		return
	end

	jobs.each(function(bufpath, job)
		vim.fn.jobstop(job.id)
		jobs.remove(bufpath)
	end)

	vim.notify('BlogkitMd: all previews stopped.', vim.log.levels.INFO)
end

function M.is_running()
	return jobs.get(vim.api.nvim_buf_get_name(0)) ~= nil
end

return M
