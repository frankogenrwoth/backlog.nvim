# backlog.nvim

A Neovim plugin designed to help you manage and persist a backlog of pending tasks with a sleek, Telescope-like interface.

## Overview

The plugin provides a dual-pane UI:
- Main Pane: Displays a table of all your tasks.
- Preview Pane: Shows details or a preview of the currently selected task.
- Interactive Input: A bottom interface for adding new tasks or commenting on existing ones.

## Folder Structure

```
backlog.nvim/
├── lua/
│   └── backlog/
│       ├── init.lua   -- Plugin entry point and setup
│       ├── ui.lua     -- UI logic for table and preview
│       └── data.lua   -- Data persistence logic
├── plugin/
│   └── backlog.lua    -- Neovim command registration
└── README.md          -- Project documentation
```

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "frankogenrwoth/backlog.nvim",
    dependencies = {
        -- Add dependencies here if needed (e.g., nvim-lua/plenary.nvim)
    },
    config = function()
        require("backlog").setup({})
    end,
}
```

## Usage

Run the following command to open the backlog interface:

```vim
:Backlog
```
