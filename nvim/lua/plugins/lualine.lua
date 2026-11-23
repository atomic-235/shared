return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.section_separators = { left = "", right = "" }
    opts.options.component_separators = { left = "", right = "" }

    -- Remove clock from statusline
    opts.sections = opts.sections or {}
    opts.sections.lualine_z = {}

    if require("config.minuet").enabled() then
      -- Minuet spinner: shows "Venice ⠙" while an inline completion is in
      -- flight, nothing when idle. Spins on the MinuetRequestStarted(Pre) and
      -- MinuetRequestFinished events.
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, 1, {
        require("minuet.lualine"),
        display_name = "provider",
        display_on_idle = false,
      })

      -- Default statusline refresh is 1000ms, which can be longer than the
      -- whole request; the spinner would never render a frame.
      opts.options.refresh = opts.options.refresh or {}
      opts.options.refresh.statusline = 150
    end
  end,
}
