-- REPL mode for zim-dsp
local M = {}

-- State for REPL session
local repl_job = nil
local repl_output_buf = nil
local repl_output_win = nil

-- Get or create output buffer
local function ensure_output_window()
  if repl_output_win and vim.api.nvim_win_is_valid(repl_output_win) then
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  
  -- Create vertical split
  vim.cmd('vsplit')
  vim.cmd('wincmd l')
  
  if not repl_output_buf or not vim.api.nvim_buf_is_valid(repl_output_buf) then
    repl_output_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(repl_output_buf, "[Zim-DSP REPL]")
    vim.api.nvim_buf_set_option(repl_output_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(repl_output_buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(repl_output_buf, 'filetype', 'zimrepl')
  end
  
  vim.api.nvim_win_set_buf(0, repl_output_buf)
  repl_output_win = vim.api.nvim_get_current_win()
  
  -- Set window width to 40% of screen
  vim.api.nvim_win_set_width(repl_output_win, math.floor(vim.o.columns * 0.4))
  
  -- Return to original window
  vim.api.nvim_set_current_win(current_win)
end

-- Append output to REPL buffer
local function append_output(lines)
  ensure_output_window()
  
  if type(lines) == "string" then
    lines = vim.split(lines, "\n")
  end
  
  -- Get current lines
  local current_lines = vim.api.nvim_buf_get_lines(repl_output_buf, 0, -1, false)
  
  -- If buffer is empty, replace first line
  if #current_lines == 1 and current_lines[1] == "" then
    vim.api.nvim_buf_set_lines(repl_output_buf, 0, -1, false, lines)
  else
    vim.api.nvim_buf_set_lines(repl_output_buf, -1, -1, false, lines)
  end
  
  -- Scroll to bottom
  local line_count = vim.api.nvim_buf_line_count(repl_output_buf)
  if repl_output_win and vim.api.nvim_win_is_valid(repl_output_win) then
    vim.api.nvim_win_set_cursor(repl_output_win, {line_count, 0})
  end
end

-- Start REPL session
function M.start()
  if repl_job then
    print("REPL already running")
    return
  end
  
  ensure_output_window()  -- Create window first
  
  local zim_dsp_path = vim.fn.stdpath("data") .. "/zim-dsp-bin/zim-dsp"
  append_output("[DEBUG] Looking for binary at: " .. zim_dsp_path)
  
  if vim.fn.executable(zim_dsp_path) == 0 then
    vim.api.nvim_err_writeln("zim-dsp not found. Run :Lazy build zim-dsp-nvim to build it.")
    return
  end
  
  append_output("Starting Zim-DSP REPL...")
  append_output("[DEBUG] Binary found, starting job...")
  
  repl_job = vim.fn.jobstart({zim_dsp_path, "repl"}, {
    pty = true,  -- Use a pseudo-terminal for interactive programs
    on_stdout = function(_, data, _)
      if data then
        vim.schedule(function()
          -- Debug: show raw data
          append_output("[DEBUG] Got " .. #data .. " lines")
          for i, line in ipairs(data) do
            append_output("[DEBUG] Line " .. i .. ": '" .. line .. "'")
            -- Handle actual content
            if line ~= "" then
              append_output(line)
            end
          end
        end)
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        vim.schedule(function()
          for i, line in ipairs(data) do
            if not (i == #data and line == "") then
              append_output("[ERROR] " .. line)
            end
          end
        end)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        append_output(string.format("\nREPL exited with code %d", exit_code))
        repl_job = nil
      end)
    end,
  })
  
  if repl_job <= 0 then
    vim.api.nvim_err_writeln("Failed to start REPL")
    repl_job = nil
  else
    append_output("[DEBUG] REPL started with job ID: " .. repl_job)
  end
end

-- Stop REPL session
function M.stop()
  if repl_job then
    vim.fn.jobstop(repl_job)
    repl_job = nil
    append_output("\nREPL stopped")
  end
end

-- Send line to REPL
function M.send_line(line)
  if not repl_job then
    M.start()
    -- Wait a bit for REPL to start
    vim.wait(500)  -- Increased wait time
  end
  
  if repl_job then
    append_output("\n>>> " .. line)
    local bytes_sent = vim.fn.chansend(repl_job, line .. "\n")
    append_output("[DEBUG] Sent " .. bytes_sent .. " bytes")
    if bytes_sent == 0 then
      append_output("[Failed to send command]")
    end
  else
    append_output("[REPL not running]")
  end
end

-- Evaluate current line
function M.eval_line(advance)
  local line = vim.api.nvim_get_current_line()
  
  -- Skip empty lines and comments
  local trimmed = line:match("^(.-)#") or line
  trimmed = vim.trim(trimmed)
  
  if trimmed ~= "" then
    M.send_line(line)
  end
  
  -- Advance to next line if requested
  if advance then
    local current_line = vim.fn.line('.')
    local last_line = vim.fn.line('$')
    if current_line < last_line then
      vim.cmd('normal! j')
    end
  end
end

-- Evaluate visual selection
function M.eval_selection()
  local utils = require("zim-dsp.utils")
  local lines = utils.get_visual_selection()
  
  for _, line in ipairs(lines) do
    -- Skip empty lines and comments
    local trimmed = line:match("^(.-)#") or line
    trimmed = vim.trim(trimmed)
    
    if trimmed ~= "" then
      M.send_line(line)
      -- Small delay between lines
      vim.wait(50)
    end
  end
end

return M