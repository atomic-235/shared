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

  -- No-op the snacks.terminal wrapper
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        override = function()
          vim.notify("Terminal disabled in this config", vim.log.levels.WARN)
        end,
      },
    },
  },

  -- Shadow the built-in :terminal ex-command (builtins can't be deleted)
  {
    "neovim",
    opts = function()
      vim.api.nvim_create_user_command("Terminal", function()
        vim.notify("Terminal disabled in this config", vim.log.levels.WARN)
      end, { nargs = "*", desc = "Terminal (disabled)" })
    end,
  },
}
