-- Nickel (.ncl) support: treesitter highlight + LSP (nls).
-- nvim recognises .ncl as filetype "nickel"; nvim-treesitter ships the parser
-- entry pointing at nickel-lang/tree-sitter-nickel, so it only needs installing.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "nickel" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nickel_ls = {},
      },
    },
  },
}
