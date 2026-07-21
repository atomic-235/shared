-- Turtle RDF (.ttl) support: treesitter highlight + filetype registration.
-- LSP not configured: turtle-language-server (Stardog, npm) is not in nixpkgs.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "turtle" },
    },
    init = function()
      -- nvim-treesitter's turtle parser entry has no `filetype` field,
      -- so register .ttl/.turtle -> "turtle" filetype ourselves.
      vim.filetype.add({
        extension = {
          ttl = "turtle",
          turtle = "turtle",
        },
      })
    end,
  },
}
