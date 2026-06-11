---
name: blogkit-md.nvim
description: A Neovim plugin that launches a live preview of the current markdown buffer using @san-siva/blogkit-md-cli
---

# blogkit-md.nvim

A Neovim plugin that launches a live preview of the current markdown buffer using [`@san-siva/blogkit-md-cli`](https://github.com/san-siva/blogkit-md-cli).

https://github.com/user-attachments/assets/604dab44-7248-4cd8-8a3c-bb3a21e1c26d

## Requirements

| Requirement    | Version |
| :------------- | :------ |
| Neovim         | 0.9+    |
| Node.js        | LTS     |
| blogkit-md-cli | latest  |

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

| Command                 | Description                                              |
| :---------------------- | :------------------------------------------------------- |
| `:BlogkitPreviewFile`   | Start a live preview of the current buffer               |
| `:BlogkitPreviewDir`    | Start a live preview of the working directory            |
| `:BlogkitPreviewStop`   | Stop every preview started this session                  |

## Usage

1. Open a markdown file in Neovim.
2. Run `:BlogkitPreviewFile` to preview the current buffer, or `:BlogkitPreviewDir` to preview the whole working directory — the browser opens automatically.
3. Edit and save; the browser reloads on every write.
4. Run `:BlogkitPreviewStop` when done. Previews are also stopped automatically when you quit Neovim.

## How it works

The plugin invokes the `blogkit-md` CLI with the buffer (or directory) path. The CLI starts a pre-built Next.js server in the background, opens the browser, and watches for changes — reloading the browser automatically on every save via SSE.

The plugin remembers each path it asked the CLI to serve. `:BlogkitPreviewStop` (and quitting Neovim) stops each of them sequentially with `blogkit-md -s <path>`.

## License

MIT

## About

- **Author:** [Santhosh Siva](https://www.santhoshsiva.dev)
- **License:** [MIT](https://github.com/san-siva/blogkit-md.nvim/blob/master/LICENSE)
