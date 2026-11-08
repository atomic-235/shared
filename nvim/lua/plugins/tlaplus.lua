-- TLA+ (.tla) support: treesitter highlight only.
-- There is no usable TLA+ language server: the official one ships bundled with
-- the VS Code extension, and tla.nvim's LSP diagnostics are still unimplemented
-- (it shells out to TLC instead). So no LSP server is registered here.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "tlaplus" },
    },
    init = function()
      -- Neovim's filetype for .tla files is "tla", the parser is "tlaplus".
      vim.treesitter.language.register("tlaplus", "tla")
    end,
  },
}
