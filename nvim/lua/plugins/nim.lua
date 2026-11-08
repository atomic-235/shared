return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- nim_format_string is a dependency of the nim parser.
      ensure_installed = { "nim", "nim_format_string" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nim_langserver = {},
      },
    },
  },
}
