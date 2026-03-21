# blogkit-md.nvim

A Neovim plugin that launches a live preview of the current markdown buffer using [`@san-siva/blogkit-md-cli`](https://github.com/san-siva/blogkit-md-cli).

https://github.com/user-attachments/assets/604dab44-7248-4cd8-8a3c-bb3a21e1c26d



## Requirements

| Requirement        | Version  |
| :----------------- | :------- |
| Neovim             | 0.9+     |
| Node.js            | LTS      |
| blogkit-md-cli     | latest   |

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
2. Run `:BlogkitPreview` — the browser opens automatically.
3. Edit and save the file; the browser reloads on every write.
4. Run `:BlogkitPreviewStop` when done.

## How it works

The plugin invokes the `blogkit-md` CLI with the current buffer's file path. The CLI starts a pre-built Next.js server, opens the browser, and watches the file for changes — reloading the browser automatically on every save via SSE.

## License

MIT

## About

- **Author:** [Santhosh Siva](https://www.santhoshsiva.dev)
- **License:** [MIT](https://github.com/san-siva/blogkit-md.nvim/blob/master/LICENSE)
