-- Nickel (.ncl) support: LSP (nls) only.
-- The tree-sitter grammar is provided by Nix in dotfiles/modules/packages.nix
-- (tree-sitter-nickel -> nvim/site/parser/nickel.so), not installed at runtime.
-- .ncl is already recognised as filetype "nickel" by Neovim.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nickel_ls = {},
      },
    },
  },
}
