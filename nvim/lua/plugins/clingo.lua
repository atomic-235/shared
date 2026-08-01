-- Clingo/ASP (.lp) support: treesitter highlight + filetype.
-- tree-sitter-clingo built via Nix (pkgs.tree-sitter.buildGrammar),
-- not in nixpkgs. Parser .so + queries loaded from Nix store via env vars.
-- Degrades gracefully if env vars unset (non-Nix machines).
return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({
        extension = {
          lp = "clingo",
          clingo = "clingo",
        },
      })

      local parser_path = vim.env.TREESITTER_CLINGO_PARSER
      if parser_path and vim.uv.fs_stat(parser_path) then
        vim.treesitter.language.add("clingo", { path = parser_path })

        local queries_dir = vim.env.TREESITTER_CLINGO_QUERIES
        if queries_dir then
          for _, qtype in ipairs({ "highlights", "injections", "indents", "textobjects" }) do
            local qpath = queries_dir .. "/" .. qtype .. ".scm"
            local f = io.open(qpath, "r")
            if f then
              vim.treesitter.query.set("clingo", qtype, f:read("*a"))
              f:close()
            end
          end
        end
      end
    end,
  },
}
