-- Markdown renderer - replaces markview.nvim for better performance
return {
  -- Disable markview
  {
    "OXY2DEV/markview.nvim",
    enabled = false,
  },
  -- render-markdown.nvim: faster, only renders visible range
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "codecompanion" },
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        enabled = true,
      },
    },
  },
}
