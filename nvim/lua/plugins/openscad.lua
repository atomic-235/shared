-- OpenSCAD (.scad) support: LSP (openscad-lsp).
-- openscad-lsp provided by Nix (pkgs.openscad-lsp), not Mason.
-- No treesitter: openscad/tree-sitter-openscad exists but is not in
-- nvim-treesitter's parser registry.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        openscad_lsp = {
          mason = false,
          cmd = { "openscad-lsp", "--stdio" },
        },
      },
    },
  },
}
