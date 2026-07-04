-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.opt.exrc = true
vim.opt.synmaxcol = 500
vim.opt.showtabline = 0

-- Use basedpyright instead of pyright for Python LSP
vim.g.lazyvim_python_lsp = "basedpyright"

-- Enable inlay hints globally by default
vim.g.lazyvim_inlay_hints = true

-- netrw (used when opening directories like `nvim .`)
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0    -- thin view (cleaner than netrw's tree)
vim.g.netrw_browse_split = 4 -- open files in previous window
vim.g.netrw_altv = 1         -- open splits to the right
vim.g.netrw_winsize = 25

-- Force usage of wl-clipboard
vim.g.clipboard = {
  name = 'wl-clipboard',
  copy = {
    ['+'] = 'wl-copy',
    ['*'] = 'wl-copy',
  },
  paste = {
    ['+'] = 'wl-paste --no-newline',
    ['*'] = 'wl-paste --no-newline',
  },
  cache_enabled = 0,
}

-- Sync system clipboard
vim.opt.clipboard = "unnamedplus"

-- NixOS: point sqlite.lua to the system-profile libsqlite3.so
-- (nix doesn't put libs in /usr/lib, so the plugin can't find it via standard paths)
local sqlite_lib = vim.env.LIBSQLITE or "/run/current-system/sw/lib/libsqlite3.so"
if vim.uv.fs_stat(sqlite_lib) then
  vim.g.sqlite_clib_path = sqlite_lib
end


