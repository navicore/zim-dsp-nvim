-- Don't load twice
if vim.g.loaded_zim_dsp then
  return
end
vim.g.loaded_zim_dsp = true

-- Commands
vim.api.nvim_create_user_command("ZimPlay", function()
  require("zim-dsp").play()
end, {})

vim.api.nvim_create_user_command("ZimStop", function()
  require("zim-dsp").stop()
end, {})

vim.api.nvim_create_user_command("ZimReload", function()
  require("zim-dsp").reload()
end, {})

-- Set up keymaps for zim files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zim",
  callback = function()
    local opts = { buffer = true, noremap = true, silent = true }
    
    -- Enter plays selection or current block
    vim.keymap.set({ "n", "v" }, "<CR>", function()
      require("zim-dsp").play_selection()
    end, opts)
    
    -- Leader mappings
    vim.keymap.set("n", "<Leader>zs", function()
      require("zim-dsp").stop()
    end, opts)
    
    vim.keymap.set("n", "<Leader>zi", function()
      require("zim-dsp").inspect()
    end, opts)
    
    vim.keymap.set("n", "<Leader>zr", function()
      require("zim-dsp").reload()
    end, opts)
  end,
})