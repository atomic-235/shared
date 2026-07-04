-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    vim.opt_local.list = false
    vim.opt_local.wrap = false
  end,
})

-- Disable wrap for markdown (markview inline virt_text wraps incorrectly with wrap on)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = false
  end,
})

-- Disable auto-pairs during macro recording
vim.api.nvim_create_autocmd("RecordingEnter", {
  callback = function()
    vim.b.minipairs_disable = true
  end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  callback = function()
    vim.b.minipairs_disable = false
  end,
})



