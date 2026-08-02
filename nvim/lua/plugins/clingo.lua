-- Clingo/ASP (.lp) support: treesitter highlight + filetype + real LSP client.
-- tree-sitter-clingo built via Nix (pkgs.tree-sitter.buildGrammar),
-- parser + queries placed in stdpath("data")/site by home-manager.
-- LSP: in-process server in lua/clingo_lsp.lua (vim.lsp.start, cmd=function).
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

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "clingo",
        group = vim.api.nvim_create_augroup("ClingoLSP", { clear = true }),
        callback = function(args)
          require("clingo_lsp").setup(args.buf)
        end,
      })
    end,
  },
}
