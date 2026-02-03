-- lua/backlog/ui.lua

-- This module handles the UI components of the backlog plugin.
-- It includes the main task table, the side preview, and the input bar.

local M = {}

-- State to keep track of windows and buffers
local state = {
  main_win = nil,
  main_buf = nil,
  preview_win = nil,
  preview_buf = nil,
  input_win = nil,
  input_buf = nil,
}

-- Function to close the backlog UI
function M.close()
  if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
    vim.api.nvim_win_close(state.main_win, true)
  end
  if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
    vim.api.nvim_win_close(state.preview_win, true)
  end
  if state.input_win and vim.api.nvim_win_is_valid(state.input_win) then
    vim.api.nvim_win_close(state.input_win, true)
  end

  state.main_win = nil
  state.preview_win = nil
  state.input_win = nil
end

-- Create a scratch buffer
local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  return buf
end

-- Function to open the backlog UI
function M.open()
  if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
    vim.api.nvim_set_current_win(state.main_win)
    return
  end

  local stats = vim.api.nvim_list_uis()[1]
  local width = stats.width
  local height = stats.height

  -- Total UI dimensions (80% of screen)
  local ui_width = math.floor(width * 0.8)
  local ui_height = math.floor(height * 0.8)
  local ui_row = math.floor((height - ui_height) / 2)
  local ui_col = math.floor((width - ui_width) / 2)

  -- Calculate individual window sizes
  local main_width = math.floor(ui_width * 0.6)
  local preview_width = ui_width - main_width - 2 -- account for borders
  local main_height = ui_height - 3 -- space for input at bottom
  local input_height = 1

  -- Create buffers
  state.main_buf = create_buffer()
  state.preview_buf = create_buffer()
  state.input_buf = create_buffer()

  -- Main Window
  state.main_win = vim.api.nvim_open_win(state.main_buf, true, {
    relative = "editor",
    width = main_width,
    height = main_height,
    row = ui_row,
    col = ui_col,
    style = "minimal",
    border = "rounded",
    title = " Backlog ",
    title_pos = "center",
  })

  -- Preview Window
  state.preview_win = vim.api.nvim_open_win(state.preview_buf, false, {
    relative = "editor",
    width = preview_width,
    height = main_height,
    row = ui_row,
    col = ui_col + main_width + 2,
    style = "minimal",
    border = "rounded",
    title = " Preview ",
    title_pos = "center",
  })

  -- Input Window
  state.input_win = vim.api.nvim_open_win(state.input_buf, false, {
    relative = "editor",
    width = ui_width,
    height = input_height,
    row = ui_row + main_height + 2,
    col = ui_col,
    style = "minimal",
    border = "rounded",
    title = " Input / Comment ",
    title_pos = "left",
  })

  -- Set keybindings for closing
  local opts = { noremap = true, silent = true, buffer = state.main_buf }
  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<Esc>", M.close, opts)

  -- Initial content (placeholder)
  vim.api.nvim_buf_set_lines(state.main_buf, 0, -1, false, { " [1] Task A", " [2] Task B", " [3] Task C" })
  vim.api.nvim_buf_set_lines(state.preview_buf, 0, -1, false, { "Detail for task A...", "Status: Pending" })
  vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, { "Type here..." })
end

-- Function to update the preview based on selected task
function M.update_preview(task_id)
  if state.preview_buf and vim.api.nvim_buf_is_valid(state.preview_buf) then
    vim.api.nvim_buf_set_lines(state.preview_buf, 0, -1, false, { "Updating preview for task: " .. task_id })
  end
end

return M
