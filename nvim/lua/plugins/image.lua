-- Inline image rendering in markdown using sixel protocol
-- Works with foot terminal (sixel support)
-- Requires: imagemagick
return {
  {
    "3rd/image.nvim",
    build = false,
    ft = "markdown",
    opts = {
      backend = "sixel",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = true,
          only_render_image_at_cursor_mode = "popup",
          filetypes = { "markdown" },
        },
      },
      max_width_window_percentage = 50,
      max_height_window_percentage = 40,
    },
  },
  -- Disable snacks inline image rendering (requires kitty protocol, not supported by foot)
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = false,
      },
    },
  },
}
