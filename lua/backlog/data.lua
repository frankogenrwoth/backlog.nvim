-- lua/backlog/data.lua

-- This module manages the data persistence for the tasks in the backlog.
-- It handles loading and saving tasks to a local JSON file.

local M = {}

local data_path = vim.fn.stdpath("data") .. "/backlog.json"

-- Initial structure: { tasks = { ["2024-02-03"] = { { id = 1, text = "Task A", comments = {} } } } }

-- Function to load tasks from storage
function M.load_tasks()
  local file = io.open(data_path, "r")
  if not file then
    return { tasks = {} }
  end

  local content = file:read("*a")
  file:close()

  if content == "" then
    return { tasks = {} }
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("backlog.nvim: Failed to parse data file", vim.log.levels.ERROR)
    return { tasks = {} }
  end

  return data
end

-- Function to save data to storage
local function save_to_disk(data)
  local file = io.open(data_path, "w")
  if not file then
    vim.notify("backlog.nvim: Failed to open data file for writing", vim.log.levels.ERROR)
    return
  end

  file:write(vim.json.encode(data))
  file:close()
end

-- Function to save a new task
-- @param task_text: The description of the task
function M.save_task(task_text)
  local data = M.load_tasks()
  local today = os.date("%Y-%m-%d")

  if not data.tasks[today] then
    data.tasks[today] = {}
  end

  -- Simple ID generation (count all tasks + 1)
  local next_id = 1
  for _, day_tasks in pairs(data.tasks) do
    next_id = next_id + #day_tasks
  end

  local new_task = {
    id = next_id,
    text = task_text,
    date = today,
    comments = {},
    status = "pending"
  }

  table.insert(data.tasks[today], new_task)
  save_to_disk(data)
  return new_task
end

-- Function to add a comment to a task
function M.add_comment(task_id, comment_text)
  local data = M.load_tasks()
  local found = false

  for _, day_tasks in pairs(data.tasks) do
    for _, task in ipairs(day_tasks) do
      if task.id == task_id then
        table.insert(task.comments, {
          text = comment_text,
          time = os.date("%Y-%m-%d %H:%M:%S")
        })
        found = true
        break
      end
    end
    if found then break end
  end

  if found then
    save_to_disk(data)
  else
    vim.notify("backlog.nvim: Task ID " .. task_id .. " not found", vim.log.levels.WARN)
  end
end

return M
