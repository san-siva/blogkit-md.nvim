# blogkit-md.nvim

A Neovim plugin that launches a live preview of the current markdown buffer using [`@san-siva/blogkit-md`](https://github.com/san-siva/blogkit-md).

<img width="1717" height="1080" alt="Screenshot 2026-03-19 at 1 18 51 PM" src="https://github.com/user-attachments/assets/f15579f9-9a75-4a03-8fc4-e0fa88333e66" />

## Requirements

| Requirement | Version  |
| :---------- | :------- |
| Neovim      | 0.9+     |
| Node.js     | LTS      |
| npm         | bundled  |

No local clone needed — dependencies are installed automatically on first use.

## Getting started

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

The plugin bootstraps a minimal Next.js workspace at `~/.local/share/nvim/blogkit-md.nvim/` and installs `@san-siva/blogkit-md` from npm on first run. Subsequent runs skip the install and start the server immediately.

A `BufWritePost` autocmd fires on every markdown save, updating a `reload-trigger.ts` file inside the workspace. Since `page.tsx` imports that file, Next.js HMR detects the change and re-renders the page — which re-reads the markdown via `BlogPost`.

## License

MIT

## About

- **Author:** [Santhosh Siva](https://www.santhoshsiva.dev)
- **License:** [MIT](https://github.com/san-siva/blogkit-md.nvim/blob/master/LICENSE)
