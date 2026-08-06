return {
  -- Kill LazyVim default terminal keymaps at spec level
  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>fT", false },
      { "<leader>ft", false },
      { "<c-/>", false },
      { "<c-_>", false },
    },
    init = function()
      vim.api.nvim_create_user_command("terminal", function()
        vim.notify("Terminal disabled in this config", vim.log.levels.WARN)
      end, { nargs = "*", desc = "terminal (disabled)" })
    end,
  },
}
