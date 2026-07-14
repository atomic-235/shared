return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Uncommitted" },
    { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Branch History" },
  },
  opts = function()
    local actions = require("diffview.actions")
    return {
      keymaps = {
        view = {
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle file panel" } },
          { "n", "<leader>b", false },
        },
        file_panel = {
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle file panel" } },
          { "n", "<leader>b", false },
        },
        file_history_panel = {
          { "n", "<leader>e", actions.toggle_files, { desc = "Toggle file panel" } },
          { "n", "<leader>b", false },
        },
      },
    }
  end,
}
