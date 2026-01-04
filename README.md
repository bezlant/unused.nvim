# unused.nvim

Track your keymap usage to identify unused keymaps for cleanup.

## Requirements

- Neovim 0.10+
- [snacks.nvim](https://github.com/folke/snacks.nvim) (for picker UI)

## Installation

### lazy.nvim

```lua
{
  "username/unused.nvim",
  priority = 10000,  -- Load before other plugins
  lazy = false,
  dependencies = { "folke/snacks.nvim" },
  config = function()
    require("unused").setup({})
  end,
}
```

**Important:** The `priority = 10000` ensures the hook installs before other plugins define keymaps.

## Usage

### Commands

- `:Unused` - Open picker showing all tracked keymaps (sorted by usage, unused first)
- `:Unused unused` - Show only keymaps with zero uses
- `:Unused reset` - Reset all usage counts

### Picker Actions

- `<CR>` - Jump to where the keymap is defined in your config

### Lua API

```lua
local unused = require("unused")

-- Get keymaps with zero uses
unused.get_unused()

-- Get all tracked keymaps with counts
unused.get_all()

-- Reset all counts
unused.reset_all()
```

## How It Works

1. Hooks `vim.keymap.set` early to capture where keymaps are defined
2. Uses `vim.on_key` to count keymap usage without modifying keymap behavior
3. Only tracks keymaps defined in your config (not plugins or defaults)
4. Persists counts to `~/.local/share/nvim/unused.json`

## Scope

Currently tracks only user-defined keymaps (via `vim.keymap.set`). Plugin keymaps and Neovim defaults are not tracked in v1.
