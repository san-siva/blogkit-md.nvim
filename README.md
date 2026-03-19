# blogkit-md.nvim

A Neovim plugin that launches a live preview of the current markdown buffer using [`@san-siva/blogkit-md`](https://github.com/san-siva/blogkit-md).

## Requirements

- Neovim 0.9+
- [blogkit-md](https://github.com/san-siva/blogkit-md) cloned locally with dependencies installed (`npm install`)

## Installation

### lazy.nvim

```lua
{
  'san-siva/blogkit-md.nvim',
  config = function()
    require('blogkit-md').setup({
      blogkit_md_dir = '/path/to/blogkit-md',
    })
  end,
}
```

### packer.nvim

```lua
use {
  'san-siva/blogkit-md.nvim',
  config = function()
    require('blogkit-md').setup({
      blogkit_md_dir = '/path/to/blogkit-md',
    })
  end,
}
```

## Setup

```lua
require('blogkit-md').setup({
  -- Path to your local blogkit-md clone (required)
  blogkit_md_dir = '/Users/you/projects/blogkit-md',
})
```

Alternatively, set the `BLOGKIT_MD_DIR` environment variable instead of passing it in `setup()`.

## Commands

| Command               | Description                                        |
| :-------------------- | :------------------------------------------------- |
| `:BlogkitPreview`     | Start a live preview of the current buffer         |
| `:BlogkitPreviewStop` | Stop the running preview                           |

## Usage

1. Open a markdown file in Neovim.
2. Run `:BlogkitPreview` — the dev server starts, watches the file for changes, and opens a browser tab automatically.
3. Edit the file; the browser reloads on save.
4. Run `:BlogkitPreviewStop` when done.

## How it works

The plugin runs `npm run dev -- --file=<buffer_path>` inside the `blogkit-md` directory as a background job. The dev server watches the markdown file via mtime polling and triggers Next.js HMR on every change.

## License

MIT
