# blogkit-md.nvim

A Neovim plugin that launches a live preview of the current markdown buffer using [`@san-siva/blogkit-md`](https://github.com/san-siva/blogkit-md).

## Requirements

- Neovim 0.9+
- Node.js + npm

No local clone needed — dependencies are installed automatically on first use.

## Installation

### lazy.nvim

```lua
{
  'san-siva/blogkit-md.nvim',
}
```

### packer.nvim

```lua
use { 'san-siva/blogkit-md.nvim' }
```

## Commands

| Command               | Description                                    |
| :-------------------- | :--------------------------------------------- |
| `:BlogkitPreview`     | Start a live preview of the current buffer     |
| `:BlogkitPreviewStop` | Stop the running preview                       |

## Usage

1. Open a markdown file in Neovim.
2. Run `:BlogkitPreview` — on first run, dependencies are installed automatically. The browser opens once the server is ready.
3. Edit and save the file; the browser reloads on every write.
4. Run `:BlogkitPreviewStop` when done.

## How it works

On first run the plugin bootstraps a minimal Next.js workspace at `~/.local/share/nvim/blogkit-md.nvim/` and runs `npm install` to fetch `@san-siva/blogkit-md` from the npm registry. Subsequent runs skip the install step and start the server immediately.

The plugin registers a `BufWritePost` autocmd on `*.md` files. On every save it updates a `reload-trigger.ts` file inside the workspace. Since `page.tsx` imports that file, Next.js HMR detects the change and re-renders the page, which re-reads the markdown file via `BlogPost`.

## License

MIT
