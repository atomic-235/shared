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
      -- Disable modelines for turtle: URIs like <https://...> and
      -- prefixed names like vi:foo trigger E518 (Unknown option) when
      -- nvim's modeline parser misreads them as option syntax.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "turtle",
        callback = function()
          vim.opt_local.modeline = false
        end,
      })
    end,
  },
}
