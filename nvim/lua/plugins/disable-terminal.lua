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
  },
}
