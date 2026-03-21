local Module = {}

local jobs = {} -- bufpath -> job_id

-- ─── Private helpers ──────────────────────────────────────────────────────────

local function launch(bufpath)
	local id = vim.fn.jobstart({ 'blogkit-md', bufpath }, {
		on_exit = function(_, code)
			if code ~= 0 and code ~= 143 then
				vim.notify('BlogkitMd: exited with code ' .. code, vim.log.levels.WARN)
			end
			jobs[bufpath] = nil
		end,
	})

	if id <= 0 then
		vim.notify('BlogkitMd: failed to start blogkit-md.', vim.log.levels.ERROR)
		return
	end

	jobs[bufpath] = id
	vim.notify('BlogkitMd: preview started for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.INFO)
end

local function ensure_cli(callback)
	if vim.fn.executable('blogkit-md') == 1 then
		callback()
		return
	end

	vim.notify('BlogkitMd: blogkit-md-cli not found. Installing via npm...', vim.log.levels.INFO)

	vim.fn.jobstart({ 'npm', 'install', '-g', '@san-siva/blogkit-md-cli' }, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify('BlogkitMd: installed successfully.', vim.log.levels.INFO)
				callback()
			else
				vim.notify(
					'BlogkitMd: installation failed. Install manually: npm install -g @san-siva/blogkit-md-cli',
					vim.log.levels.ERROR
				)
			end
		end,
	})
end

-- ─── Public API ──────────────────────────────────────────────────────────────

function Module.setup(opts)
	Module.config = opts or {}
end

function Module.start()
	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == '' then
		vim.notify('BlogkitMd: current buffer has no file path.', vim.log.levels.ERROR)
		return
	end

	if jobs[bufpath] ~= nil then
		vim.notify('BlogkitMd: preview already running for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.WARN)
		return
	end

	ensure_cli(function()
		launch(bufpath)
	end)
end

function Module.stop()
	local bufpath = vim.api.nvim_buf_get_name(0)

	if jobs[bufpath] == nil then
		vim.notify('BlogkitMd: no preview running for this buffer.', vim.log.levels.WARN)
		return
	end

	vim.fn.jobstop(jobs[bufpath])
	jobs[bufpath] = nil
	vim.notify('BlogkitMd: preview stopped for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.INFO)
end

function Module.stop_all()
	if next(jobs) == nil then
		vim.notify('BlogkitMd: no previews running.', vim.log.levels.WARN)
		return
	end

	for bufpath, id in pairs(jobs) do
		vim.fn.jobstop(id)
		jobs[bufpath] = nil
	end

	vim.notify('BlogkitMd: all previews stopped.', vim.log.levels.INFO)
end

function Module.is_running()
	local bufpath = vim.api.nvim_buf_get_name(0)
	return jobs[bufpath] ~= nil
end

return Module
