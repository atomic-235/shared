-- Cypher (.cypher) support: treesitter highlight for .cypher files, and for
-- Cypher injected into Python strings via a `# cypher` comment above them.
-- tree-sitter-cypher (simplificare-org, openCypher) built via Nix like clingo;
-- parser in stdpath("data")/site by home-manager, highlights in queries/cypher.
-- Degrades gracefully if parser not found (non-Nix machines).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.filetype.add({
        extension = {
          cypher = "cypher",
        },
      })

      local parser_path = vim.fn.stdpath("data") .. "/site/parser/cypher.so"
      if vim.uv.fs_stat(parser_path) then
        vim.treesitter.language.add("cypher", { path = parser_path })
      end
    end,
  },
}
