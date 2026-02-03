-- plugin/backlog.lua

-- This file is automatically loaded by Neovim on startup if the plugin is installed.
-- It exposes the user-facing commands and initializes the plugin if needed.

if vim.fn.has("nvim-0.7.0") == 0 then
  vim.api.nvim_err_writeln("backlog.nvim requires Neovim 0.7.0 or later")
  return
end

-- Create a command to trigger the backlog UI
vim.api.nvim_create_user_command("Backlog", function()
  require("backlog.ui").open()
end, { desc = "Open the backlog UI" })

-- Initialization (if any global setup is needed)
-- require("backlog").setup({})
