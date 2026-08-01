-- Clingo/ASP (.lp) support: treesitter highlight + filetype.
-- tree-sitter-clingo built via Nix (pkgs.tree-sitter.buildGrammar),
-- parser + queries placed in stdpath("data")/site by home-manager.
-- Degrades gracefully if parser not found (non-Nix machines).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.filetype.add({
        extension = {
          lp = "clingo",
          clingo = "clingo",
        },
      })

      local parser_path = vim.fn.stdpath("data") .. "/site/parser/clingo.so"
      if vim.uv.fs_stat(parser_path) then
        vim.treesitter.language.add("clingo", { path = parser_path })
      end
    end,
  },
}
