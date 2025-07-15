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
- `:ZimRepl` - Start REPL mode
- `:ZimReplStop` - Stop REPL mode

### Keybindings

In `.zim` files:
- `<Enter>` - Play selected lines or current block (in REPL mode: execute line by line)
- `<Leader>zs` - Stop playback
- `<Leader>zi` - Inspect module under cursor
- `<Leader>zr` - Reload current patch

### Modes

The plugin supports two modes:

1. **File Mode** (default): Treats code as complete patches that define a graph
2. **REPL Mode**: Executes commands line by line, maintaining state between commands

### Configuration

```lua
require("zim-dsp").setup({
  -- Auto-reload on save
  auto_reload = true,
  
  -- Show module info in floating window
  float_preview = true,
  
  -- Use REPL mode instead of file mode
  repl_mode = false,
  
  -- Auto-start REPL when opening .zim files (requires repl_mode = true)
  auto_start_repl = false,
})
```

### REPL Mode Example

```lua
-- Enable REPL mode in your config
require("zim-dsp").setup({
  repl_mode = true,
  auto_start_repl = true,
})
```

Then in a `.zim` file:
- Press Enter on each line to execute it
- Visual select multiple lines and press Enter to execute them in sequence
- The REPL maintains state, so you can build up patches incrementally

## License

MIT