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

### Adding a Task
1. Inside the Backlog UI, press `i` to focus the **Input Bar**.
2. Type your task description.
3. Press `<Enter>` to save. The task will be added to today's group.

### Commenting on a Task
1. Press `i` to focus the **Input Bar**.
2. Type `c [ID] [Message]`. For example: `c 1 This task is almost done`.
3. Press `<Enter>` to save.
4. You can see the comments in the **Preview Pane** as you move your cursor over the tasks in the main window.

### Marking a Task as Complete
1. Hover over a task in the **Main Window**.
2. Press `x`. The checkbox will toggle between `[ ]` and `[x]`.

### Reloading the UI
- Press `R` in the **Main Window** to force a refresh of the UI and recalculate table layouts.

### Navigation
- `j` / `k`: Move selection (Preview updates automatically).
- `i`: Focus Input Bar.
- `x`: Toggle task completion.
- `R`: Reload UI.
- `q` or `<Esc>`: Close the UI.
