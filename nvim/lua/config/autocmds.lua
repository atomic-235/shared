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

-- Replace LazyVim's lazyvim_wrap_spell: keep spell checking for text filetypes
-- but drop the wrap=true part so manual wrap toggles survive `:e` (FileType
-- autocmds re-fire on `:e`, which was resetting wrap). Global nowrap default
-- from LazyVim applies; per-buffer toggles now persist.
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wrap_spell_noset", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
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



