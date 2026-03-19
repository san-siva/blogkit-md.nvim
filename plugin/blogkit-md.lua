local blogkit = require('blogkit-md')

vim.api.nvim_create_user_command('BlogkitPreview', function()
	blogkit.start()
end, { desc = 'Start blogkit-md live preview for current buffer' })

vim.api.nvim_create_user_command('BlogkitPreviewStop', function()
	blogkit.stop()
end, { desc = 'Stop blogkit-md live preview' })
