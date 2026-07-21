-- Turtle RDF (.ttl) support: treesitter highlight + filetype + LSP (swls).
-- swls (Semantic Web Language Server) handles Turtle/TriG/JSON-LD/SPARQL.
-- Pinned via nix flake input (swls-v0.4.1). Not in nixpkgs or lspconfig.
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
          -- swls also supports these, but we only register .ttl/.turtle
          -- to avoid surprising users with new filetype mappings.
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
  -- Register swls as a new lspconfig server (not in upstream lspconfig).
  -- swls speaks standard LSP over stdio. Configuration mirrors the
  -- upstream swls.nvim plugin defaults.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        swls = {
          mason = false,
          cmd = { "swls" },
          filetypes = { "turtle" },
          root_markers = { ".git" },
          init_options = {
            -- SPARQL support is experimental per swls docs; leave off.
            sparql = false,
          },
        },
      },
    },
  },
}
