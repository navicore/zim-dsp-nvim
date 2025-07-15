local M = {}

-- Get the current block of code (paragraph)
function M.get_current_block()
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")
  local lines = {}
  
  -- Find start of block (go up until empty line or start of file)
  local start_line = current_line
  while start_line > 1 do
    local prev_line = vim.fn.getline(start_line - 1)
    if prev_line:match("^%s*$") then
      break
    end
    start_line = start_line - 1
  end
  
  -- Find end of block (go down until empty line or end of file)
  local end_line = current_line
  while end_line < total_lines do
    local next_line = vim.fn.getline(end_line + 1)
    if next_line:match("^%s*$") then
      break
    end
    end_line = end_line + 1
  end
  
  -- Collect non-empty lines
  for i = start_line, end_line do
    local line = vim.fn.getline(i)
    if not line:match("^%s*$") then
      table.insert(lines, line)
    end
  end
  
  return lines
end

-- Get visual selection
function M.get_visual_selection()
  local lines = {}
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  
  for i = start_line, end_line do
    table.insert(lines, vim.fn.getline(i))
  end
  
  return lines
end

-- Find module definition for word under cursor
function M.find_module_definition(word)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  
  for i, line in ipairs(lines) do
    -- Match module definition pattern
    local module_name = line:match("^%s*(" .. word .. "):")
    if module_name then
      return i, line
    end
  end
  
  return nil, nil
end

-- Create a scratch buffer with content
function M.create_scratch_buffer(lines, filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  if filetype then
    vim.api.nvim_buf_set_option(buf, "filetype", filetype)
  end
  
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  
  return buf
end

return M