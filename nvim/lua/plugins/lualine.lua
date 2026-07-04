return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }

    -- Remove clock from statusline
    opts.sections = opts.sections or {}
    opts.sections.lualine_z = {}
  end,
}
