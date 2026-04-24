local jobs = require 'blogkit-md.jobs'

local M = {}

function M.open_browser(port)
	local url = 'http://localhost:' .. port
	if vim.ui and vim.ui.open then
		vim.ui.open(url)
	elseif vim.fn.has('mac') == 1 then
		vim.fn.jobstart({ 'open', url })
	else
		vim.fn.jobstart({ 'xdg-open', url })
	end
end

function M.launch(bufpath)
	local port = jobs.next_port()
	local id = vim.fn.jobstart({ 'blogkit-md', bufpath, '--port=' .. port }, {
		on_exit = function(_, code)
			if code ~= 0 and code ~= 143 then
				vim.notify('BlogkitMd: exited with code ' .. code, vim.log.levels.WARN)
			end
			jobs.remove(bufpath)
		end,
	})

	if id <= 0 then
		vim.notify('BlogkitMd: failed to start blogkit-md.', vim.log.levels.ERROR)
		return
	end

	jobs.set(bufpath, id, port)
	vim.notify(
		'BlogkitMd: preview started for ' .. vim.fn.fnamemodify(bufpath, ':t') .. ' on port ' .. port,
		vim.log.levels.INFO
	)
	M.open_browser(port)
end

function M.ensure_cli(callback)
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

return M
