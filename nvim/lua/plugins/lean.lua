-- Lean 4 (.lean) support: treesitter highlight + LSP (leanls via lean.nvim).
-- lean.nvim provides infoview, diagnostics, hover, completion, go-to-definition.
-- lean.nvim installs its own tree-sitter-lean parser; nvim-treesitter's
-- ensure_installed does not support "lean" (not in its parser registry).
return {
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
