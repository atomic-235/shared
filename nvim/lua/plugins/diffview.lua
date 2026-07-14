return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Uncommitted" },
    { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Branch History" },
  },
  opts = {},
}
