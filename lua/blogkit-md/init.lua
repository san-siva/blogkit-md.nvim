local M = {}

local job_id = nil

local function find_blogkit_md_dir()
	-- Check config option first
	if M.config and M.config.blogkit_md_dir then
		return M.config.blogkit_md_dir
	end
	-- Fall back to env var
	local env = os.getenv('BLOGKIT_MD_DIR')
	if env and env ~= '' then
		return env
	end
	return nil
end

function M.setup(opts)
	M.config = opts or {}
end

function M.start()
	if job_id ~= nil then
		vim.notify('BlogkitMd: preview is already running. Use :BlogkitPreviewStop to stop it.', vim.log.levels.WARN)
		return
	end

	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == '' then
		vim.notify('BlogkitMd: current buffer has no file path.', vim.log.levels.ERROR)
		return
	end

	local dir = find_blogkit_md_dir()
	if not dir then
		vim.notify(
			'BlogkitMd: blogkit-md directory not set. Pass blogkit_md_dir in setup() or set $BLOGKIT_MD_DIR.',
			vim.log.levels.ERROR
		)
		return
	end

	local cmd = string.format('cd %s && npm run dev -- --file=%s', vim.fn.shellescape(dir), vim.fn.shellescape(bufpath))

	job_id = vim.fn.jobstart({ 'sh', '-c', cmd }, {
		on_exit = function(_, code)
			if code ~= 0 and code ~= 143 then
				vim.notify('BlogkitMd: dev server exited with code ' .. code, vim.log.levels.WARN)
			end
			job_id = nil
		end,
	})

	if job_id <= 0 then
		vim.notify('BlogkitMd: failed to start dev server.', vim.log.levels.ERROR)
		job_id = nil
		return
	end

	vim.notify('BlogkitMd: preview started for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.INFO)
end

function M.stop()
	if job_id == nil then
		vim.notify('BlogkitMd: no preview is running.', vim.log.levels.WARN)
		return
	end

	vim.fn.jobstop(job_id)
	job_id = nil
	vim.notify('BlogkitMd: preview stopped.', vim.log.levels.INFO)
end

function M.is_running()
	return job_id ~= nil
end

return M
