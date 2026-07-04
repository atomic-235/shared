return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
    { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Branch History" },
  },
  opts = {},
}
