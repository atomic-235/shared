-- Clingo/ASP (.lp) support: treesitter highlight + filetype.
-- tree-sitter-clingo by Potassco provides syntax highlighting.
-- No LSP exists for clingo in lspconfig (asp-lsp has 2 stars, not packaged).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "clingo" },
    },
    init = function()
      vim.filetype.add({
        extension = {
          lp = "clingo",
          clingo = "clingo",
        },
      })
    end,
  },
}
