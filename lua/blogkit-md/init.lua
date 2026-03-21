local Module = {}

local job_id = nil

-- ─── Public API ──────────────────────────────────────────────────────────────

function Module.setup(opts)
	Module.config = opts or {}
end

function Module.start()
	if job_id ~= nil then
		vim.notify('BlogkitMd: preview is already running. Use :BlogkitPreviewStop to stop it.', vim.log.levels.WARN)
		return
	end

	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == '' then
		vim.notify('BlogkitMd: current buffer has no file path.', vim.log.levels.ERROR)
		return
	end

	job_id = vim.fn.jobstart({ 'blogkit-md', bufpath }, {
		on_exit = function(_, code)
			if code ~= 0 and code ~= 143 then
				vim.notify('BlogkitMd: exited with code ' .. code, vim.log.levels.WARN)
			end
			job_id = nil
		end,
	})

	if job_id <= 0 then
		vim.notify('BlogkitMd: failed to start. Is blogkit-md installed? (npm install -g @san-siva/blogkit-md-cli)', vim.log.levels.ERROR)
		job_id = nil
		return
	end

	vim.notify('BlogkitMd: preview started for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.INFO)
end

function Module.stop()
	if job_id == nil then
		vim.notify('BlogkitMd: no preview is running.', vim.log.levels.WARN)
		return
	end

	vim.fn.jobstop(job_id)
	job_id = nil

	vim.notify('BlogkitMd: preview stopped.', vim.log.levels.INFO)
end

function Module.is_running()
	return job_id ~= nil
end

return Module
