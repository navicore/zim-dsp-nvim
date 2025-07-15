# zim-dsp-nvim

Neovim plugin for [zim-dsp](https://github.com/navicore/zim-dsp) modular synthesizer patches.

## Features

- Syntax highlighting for `.zim` files
- Play patches or selected blocks with `<Enter>`
- Live coding support with hot-reload
- Module introspection
- Automatic building from source

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "navicore/zim-dsp-nvim",
  ft = "zim",
  build = "./build.lua",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("zim-dsp").setup()
  end,
}
```

## Requirements

- Neovim 0.5+
- Rust toolchain (cargo) for building zim-dsp
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- zim-dsp source code at `~/git/navicore/zim-dsp`

## Building

The plugin builds zim-dsp from source on installation. The binary is installed to `~/.local/share/nvim/zim-dsp-bin/`.

To manually rebuild:
```vim
:Lazy build zim-dsp-nvim
```

## Usage

### Commands

- `:ZimPlay` - Play the current file
- `:ZimStop` - Stop playback
- `:ZimReload` - Reload the current patch (if playing)

### Keybindings

In `.zim` files:
- `<Enter>` - Play selected lines or current block
- `<Leader>zs` - Stop playback
- `<Leader>zi` - Inspect module under cursor
- `<Leader>zr` - Reload current patch

### Configuration

```lua
require("zim-dsp").setup({
  -- Auto-reload on save
  auto_reload = true,
  
  -- Show module info in floating window
  float_preview = true,
})
```

## License

MIT