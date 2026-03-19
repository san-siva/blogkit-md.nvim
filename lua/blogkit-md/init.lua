local Module = {}

local job_id = nil
local autocmd_id = nil
local browser_opened = false

local workspace_dir = vim.fn.stdpath('data') .. '/blogkit-md.nvim'

-- ─── Workspace template files ────────────────────────────────────────────────

local workspace_files = {
	['package.json'] = [[{
  "name": "blogkit-md-preview",
  "private": true,
  "scripts": {
    "dev": "next dev"
  },
  "dependencies": {
    "@san-siva/blogkit-md": "latest",
    "next": "latest",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  }
}
]],
	['next.config.mjs'] = [[/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@san-siva/blogkit-md'],
};
export default nextConfig;
]],
	['tsconfig.json'] = [[{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }]
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
]],
	['app/layout.tsx'] = [[export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
]],
	['app/page.tsx'] = [[import { BlogPost } from '@san-siva/blogkit-md';
import { reloadTrigger } from './reload-trigger';

export default function Page() {
  void reloadTrigger;
  const filePath = process.env.MARKDOWN_FILE ?? '';
  if (!filePath) {
    return <p style={{ padding: '2rem', fontFamily: 'monospace' }}>No markdown file specified.</p>;
  }
  return <BlogPost filePath={filePath} />;
}
]],
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function write_file(path, content)
	local f = io.open(path, 'w')
	if f then
		f:write(content)
		f:close()
	end
end

local function ensure_workspace_files()
	vim.fn.mkdir(workspace_dir .. '/app', 'p')
	for rel, content in pairs(workspace_files) do
		write_file(workspace_dir .. '/' .. rel, content)
	end
	local trigger = workspace_dir .. '/app/reload-trigger.ts'
	if vim.fn.filereadable(trigger) == 0 then
		write_file(trigger, "export const reloadTrigger = '0';\n")
	end
end

local function update_trigger()
	write_file(
		workspace_dir .. '/app/reload-trigger.ts',
		"export const reloadTrigger = '" .. os.time() .. "';\n"
	)
end

-- ─── Dev server ──────────────────────────────────────────────────────────────

local function start_dev_server(bufpath)
	browser_opened = false

	local cmd = string.format(
		'cd %s && MARKDOWN_FILE=%s npm run dev',
		vim.fn.shellescape(workspace_dir),
		vim.fn.shellescape(bufpath)
	)

	job_id = vim.fn.jobstart({ 'sh', '-c', cmd }, {
		stdout_buffered = false,
		on_stdout = function(_, data)
			if browser_opened then return end
			for _, line in ipairs(data) do
				local url = line:match('http://localhost:%d+')
				if url then
					browser_opened = true
					vim.fn.jobstart({ 'open', url })
					break
				end
			end
		end,
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

	autocmd_id = vim.api.nvim_create_autocmd('BufWritePost', {
		pattern = '*.md',
		callback = update_trigger,
	})

	vim.notify('BlogkitMd: preview started for ' .. vim.fn.fnamemodify(bufpath, ':t'), vim.log.levels.INFO)
end

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

	ensure_workspace_files()

	if vim.fn.isdirectory(workspace_dir .. '/node_modules') == 0 then
		vim.notify('BlogkitMd: installing dependencies (first run)...', vim.log.levels.INFO)
		vim.fn.jobstart({ 'npm', 'install', '--prefix', workspace_dir }, {
			on_exit = function(_, code)
				if code ~= 0 then
					vim.notify('BlogkitMd: npm install failed.', vim.log.levels.ERROR)
					return
				end
				vim.notify('BlogkitMd: dependencies installed.', vim.log.levels.INFO)
				start_dev_server(bufpath)
			end,
		})
	else
		start_dev_server(bufpath)
	end
end

function Module.stop()
	if job_id == nil then
		vim.notify('BlogkitMd: no preview is running.', vim.log.levels.WARN)
		return
	end

	vim.fn.jobstop(job_id)
	job_id = nil

	if autocmd_id ~= nil then
		vim.api.nvim_del_autocmd(autocmd_id)
		autocmd_id = nil
	end

	vim.notify('BlogkitMd: preview stopped.', vim.log.levels.INFO)
end

function Module.is_running()
	return job_id ~= nil
end

return Module
