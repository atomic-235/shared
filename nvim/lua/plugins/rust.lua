return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- rust has no LazyVim lang extra here (rust.lua only wires rust-analyzer),
      -- so nothing pulls the parser in. Without it nvim falls back to legacy
      -- regex syntax, and nvim-diff-render's fallback path is what corrupts
      -- rust diffs in lazygit.
      ensure_installed = { "rust", "sql" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- after/queries/rust/injections.scm colours SQL inside sqlx macros, but
      -- rust-analyzer's semantic tokens paint the whole literal with
      -- @lsp.type.string.rust at a higher priority. Clearing the group lets the
      -- injected SQL show through; plain strings keep their @string colour.
      local function clear()
        vim.api.nvim_set_hl(0, "@lsp.type.string.rust", {})
      end
      clear()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = clear })
    end,
    opts = {
      servers = {
        rust_analyzer = {},
      },
    },
  },
}
