-- Lean 4 (.lean) support: treesitter highlight + LSP (leanls via lean.nvim).
-- lean.nvim provides infoview, diagnostics, hover, completion, go-to-definition.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lean" },
    },
  },
  {
    "Julian/lean.nvim",
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      mappings = true,
    },
  },
}
