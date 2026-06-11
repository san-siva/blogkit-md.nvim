local blogkit = require('blogkit-md')

vim.api.nvim_create_user_command('BlogkitPreviewFile', function()
	blogkit.preview_file()
end, { desc = 'Start a blogkit-md preview for the current buffer' })

vim.api.nvim_create_user_command('BlogkitPreviewDir', function()
	blogkit.preview_dir()
end, { desc = 'Start a blogkit-md preview for the working directory' })

vim.api.nvim_create_user_command('BlogkitPreviewStop', function()
	blogkit.stop()
end, { desc = 'Stop all blogkit-md previews started this session' })

vim.api.nvim_create_augroup('BlogkitMd', { clear = true })
vim.api.nvim_create_autocmd('VimLeavePre', {
	group = 'BlogkitMd',
	desc = 'Stop blogkit-md previews on exit',
	callback = function()
		blogkit.stop({ quiet = true })
	end,
})
