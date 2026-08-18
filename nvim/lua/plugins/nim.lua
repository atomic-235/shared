-- Nim (.nim, .nims, .nimble) support: treesitter highlight + LSP (nimlangserver).
-- nimlangserver provided by Nix (pkgs.nimlangserver), not Mason.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "nim" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nim_langserver = {
          mason = false,
          cmd = { "nimlangserver" },
        },
      },
    },
  },
}
