-- lua/backlog/ui.lua

-- This module handles the UI components of the backlog plugin.
-- It includes the main task table, the side preview, and the input bar.

local M = {}
local data = require("backlog.data")

-- State to keep track of windows and buffers
local state = {
  main_win = nil,
  main_buf = nil,
  preview_win = nil,
  preview_buf = nil,
  input_win = nil,
  input_buf = nil,
  selected_task_id = nil,
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

-- Render tasks in the main buffer
local function render_main_content()
  local task_data = data.load_tasks()
  local lines = {}
  local task_map = {} -- Map line number to task object

  local stats = vim.api.nvim_win_get_config(state.main_win)
  local win_width = stats.width

  -- Column widths
  local col_st = 5
  local col_id = 5
  local col_desc = win_width - col_st - col_id - 4 -- accounting for separators │

  local top_border = "┌" .. string.rep("─", col_st) .. "┬" .. string.rep("─", col_id) .. "┬" .. string.rep("─", col_desc) .. "┐"
  local header = "│ ST  │ ID  │ " .. string.format("%-" .. (col_desc - 1) .. "s", "Task Description") .. "│"
  local separator = "├" .. string.rep("─", col_st) .. "┼" .. string.rep("─", col_id) .. "┼" .. string.rep("─", col_desc) .. "┤"
  local bottom_border = "└" .. string.rep("─", col_st) .. "┴" .. string.rep("─", col_id) .. "┴" .. string.rep("─", col_desc) .. "┘"

  local dates = {}
  for date in pairs(task_data.tasks) do
    table.insert(dates, date)
  end
  table.sort(dates, function(a, b) return a > b end) -- Newest first

  if #dates == 0 then
    vim.api.nvim_buf_set_lines(state.main_buf, 0, -1, false, { " No tasks found. Press 'i' to add one!" })
    return
  end

  for _, date in ipairs(dates) do
    table.insert(lines, "─── " .. date .. " ───")
    table.insert(lines, top_border)
    table.insert(lines, header)
    table.insert(lines, separator)
    
    for _, task in ipairs(task_data.tasks[date]) do
      local checkbox = task.status == "completed" and "[x]" or "[ ]"
      
      -- Format description with truncation
      local desc = task.text
      if #desc > (col_desc - 2) then
        desc = desc:sub(1, col_desc - 5) .. "..."
      end
      
      local line_text = string.format("│ %-3s │ %3d │ %-" .. (col_desc - 1) .. "s│", checkbox, task.id, desc)
      table.insert(lines, line_text)
      task_map[#lines] = task
    end
    table.insert(lines, bottom_border)
    table.insert(lines, "")
  end

  vim.api.nvim_buf_set_lines(state.main_buf, 0, -1, false, lines)
  state.task_map = task_map
end

-- Function to handle task addition from input bar
local function handle_input_submit()
  local lines = vim.api.nvim_buf_get_lines(state.input_buf, 0, -1, false)
  local input_text = table.concat(lines, " "):gsub("^%s*(.-)%s*$", "%1")

  if input_text == "" or input_text == "Type here..." then
    return
  end

  -- Check if it's a comment command: "c [id] [text]"
  local task_id, comment = input_text:match("^c%s+(%d+)%s+(.+)$")
  if task_id and comment then
    data.add_comment(tonumber(task_id), comment)
  else
    data.save_task(input_text)
  end

  -- Clear input and refresh
  vim.api.nvim_buf_set_lines(state.input_buf, 0, -1, false, { "" })
  render_main_content()
  
  -- Move focus back to main window if we were in input
  if vim.api.nvim_get_current_win() == state.input_win then
    vim.api.nvim_set_current_win(state.main_win)
  end
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
  local preview_width = ui_width - main_width - 2
  local main_height = ui_height - 3
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
    title = " Input (Type to add, 'c ID msg' to comment) ",
    title_pos = "left",
  })

  -- Keybindings
  local opts = { noremap = true, silent = true, buffer = state.main_buf }
  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<Esc>", M.close, opts)
  vim.keymap.set("n", "i", function()
    vim.api.nvim_set_current_win(state.input_win)
    vim.api.nvim_feedkeys("A", "n", false) -- Enter insert mode
  end, opts)

  -- Input window submit on Enter
  vim.keymap.set("i", "<CR>", function()
    handle_input_submit()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end, { buffer = state.input_buf })

  -- Cursor move updating preview
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = state.main_buf,
    callback = function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = cursor[1]
      local task = state.task_map and state.task_map[line]
      if task then
        M.update_preview(task)
      end
    end,
  })

  render_main_content()
end

-- Function to update the preview based on selected task
function M.update_preview(task)
  if not state.preview_buf or not vim.api.nvim_buf_is_valid(state.preview_buf) then return end

  local lines = {
    "Task ID: " .. task.id,
    "Status: " .. task.status,
    "Created: " .. task.date,
    "",
    "Description:",
    "  " .. task.text,
    "",
    "Comments:",
  }

  if #task.comments == 0 then
    table.insert(lines, "  (No comments yet)")
  else
    for _, comment in ipairs(task.comments) do
      table.insert(lines, string.format("  [%s] %s", comment.time:sub(1, 16), comment.text))
    end
  end

  vim.api.nvim_buf_set_lines(state.preview_buf, 0, -1, false, lines)
end

return M
