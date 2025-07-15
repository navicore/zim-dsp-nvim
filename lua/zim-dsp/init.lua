local M = {}

-- Default configuration
M.config = {
  auto_reload = true,
  float_preview = true,
}

-- State
local current_job = nil
local current_file = nil

-- Get the path to the zim-dsp binary
local function get_zim_dsp_path()
  return vim.fn.stdpath("data") .. "/zim-dsp-bin/zim-dsp"
end

-- Check if zim-dsp is available
local function check_zim_dsp()
  local path = get_zim_dsp_path()
  return vim.fn.executable(path) == 1
end


-- Setup function
function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  
  -- Check if zim-dsp is available
  if not check_zim_dsp() then
    vim.notify("[zim-dsp] Binary not found. Run :Lazy build zim-dsp-nvim to build it.", vim.log.levels.WARN)
  end
  
  -- Set up autocmds
  vim.api.nvim_create_augroup("ZimDsp", { clear = true })
  
  if M.config.auto_reload then
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = "ZimDsp",
      pattern = "*.zim",
      callback = function()
        if current_job and current_file == vim.fn.expand("%:p") then
          M.reload()
        end
      end,
    })
  end
end

-- Stop current playback
function M.stop()
  if current_job then
    vim.fn.jobstop(current_job)
    current_job = nil
    current_file = nil
    print("Stopped zim-dsp")
  end
end

-- Play a file
function M.play_file(file)
  -- Ensure zim-dsp is available
  if not check_zim_dsp() then
    vim.api.nvim_err_writeln("zim-dsp not found. Run :Lazy build zim-dsp-nvim to build it.")
    return
  end
  
  M.stop()
  
  local cmd = { get_zim_dsp_path(), "play", file }
  
  current_job = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        print("zim-dsp finished")
      else
        print("zim-dsp exited with code: " .. exit_code)
      end
      current_job = nil
      current_file = nil
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.api.nvim_err_writeln("zim-dsp: " .. line)
        end
      end
    end,
  })
  
  if current_job > 0 then
    current_file = file
    print("Playing: " .. file)
  else
    vim.api.nvim_err_writeln("Failed to start zim-dsp")
  end
end

-- Play current file
function M.play()
  local file = vim.fn.expand("%:p")
  M.play_file(file)
end

-- Play selected lines or current block
function M.play_selection()
  local utils = require("zim-dsp.utils")
  
  -- Get selected lines or current paragraph
  local lines = {}
  local mode = vim.fn.mode()
  
  if mode == "v" or mode == "V" then
    lines = utils.get_visual_selection()
  else
    lines = utils.get_current_block()
  end
  
  if #lines == 0 then
    print("No lines to play")
    return
  end
  
  -- Create temporary file
  local tmpfile = vim.fn.tempname() .. ".zim"
  local f = io.open(tmpfile, "w")
  if not f then
    vim.api.nvim_err_writeln("Failed to create temporary file")
    return
  end
  
  for _, line in ipairs(lines) do
    f:write(line .. "\n")
  end
  f:close()
  
  -- Play the temporary file
  M.play_file(tmpfile)
  
  -- Clean up temp file after a delay
  vim.defer_fn(function()
    vim.fn.delete(tmpfile)
  end, 1000)
end

-- Reload current patch (stop and play again)
function M.reload()
  if current_file then
    local file = current_file
    M.stop()
    vim.defer_fn(function()
      M.play_file(file)
    end, 100)
  end
end

-- Inspect module under cursor
function M.inspect()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    print("No module under cursor")
    return
  end
  
  -- Ensure zim-dsp is available
  if not check_zim_dsp() then
    vim.api.nvim_err_writeln("zim-dsp not found. Run :Lazy build zim-dsp-nvim to build it.")
    return
  end
  
  -- Create a temporary REPL session to inspect the module
  local cmd = { get_zim_dsp_path(), "repl" }
  local output = {}
  
  local job = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        table.insert(output, line)
      end
    end,
  })
  
  -- Send commands to inspect
  vim.fn.chansend(job, "inspect " .. word .. "\n")
  vim.fn.chansend(job, "quit\n")
  
  -- Wait for completion
  vim.fn.jobwait({ job }, 1000)
  
  -- Display output
  if M.config.float_preview then
    M.show_float(output)
  else
    for _, line in ipairs(output) do
      if line:match("Module:") or line:match("Inputs:") or line:match("Outputs:") then
        print(line)
      end
    end
  end
end

-- Show output in floating window
function M.show_float(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  local width = 60
  local height = math.min(#lines, 20)
  
  local opts = {
    relative = "cursor",
    width = width,
    height = height,
    row = 1,
    col = 0,
    style = "minimal",
    border = "rounded",
  }
  
  local win = vim.api.nvim_open_win(buf, false, opts)
  
  -- Close on any key press
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
end

return M