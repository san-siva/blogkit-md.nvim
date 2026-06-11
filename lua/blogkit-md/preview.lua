local registry = require 'blogkit-md.registry'

local M = {}

-- Start a background preview for the given file or directory path. The CLI
-- opens the browser itself and reuses any existing server for the same path,
-- so this is safe to call repeatedly.
function M.start(path)
	local id = vim.fn.jobstart({ 'blogkit-md', path }, {
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
