# zim-dsp-nvim

Neovim plugin for [zim-dsp](https://github.com/navicore/zim-dsp) modular synthesizer patches.

## Features

- Syntax highlighting for `.zim` files
- Play patches or selected blocks with `<Enter>`
- Live coding support with hot-reload
- Module introspection

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "navicore/zim-dsp-nvim",
  ft = "zim",
  config = function()
    require("zim-dsp").setup()
  end,
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "navicore/zim-dsp-nvim",
  ft = "zim",
  config = function()
    require("zim-dsp").setup()
  end,
}
```

## Requirements

- Neovim 0.5+
- [zim-dsp](https://github.com/navicore/zim-dsp) installed and in PATH

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

### Configuration

```lua
require("zim-dsp").setup({
  -- Path to zim-dsp executable
  zim_dsp_path = "zim-dsp",
  
  -- Auto-reload on save
  auto_reload = true,
  
  -- Show module info in floating window
  float_preview = true,
})
```

## License

MIT