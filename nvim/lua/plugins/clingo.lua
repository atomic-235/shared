-- Clingo/ASP (.lp) support: treesitter highlight + filetype.
-- tree-sitter-clingo by Potassco provides syntax highlighting.
-- Not in nvim-treesitter's bundled registry, so registered manually.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.clingo = {
        install_info = {
          url = "https://github.com/potassco/tree-sitter-clingo",
          files = { "src/parser.c" },
        },
        filetype = "clingo",
      }
      vim.filetype.add({
        extension = {
          lp = "clingo",
          clingo = "clingo",
        },
      })
    end,
  },
}
