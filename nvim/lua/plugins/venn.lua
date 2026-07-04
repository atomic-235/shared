return {
  "jbyuki/venn.nvim",
  keys = {
    { "<leader>v", desc = "Venn toggle" },
  },
  config = function()
    local venn_enabled = false

    local function toggle_venn()
      venn_enabled = not venn_enabled
      if venn_enabled then
        vim.cmd("setlocal ve=all")
        vim.b.snacks_indent_disable = true
        vim.keymap.set("n", "J", "<C-v>j:VBox<CR>", { buffer = true })
        vim.keymap.set("n", "K", "<C-v>k:VBox<CR>", { buffer = true })
        vim.keymap.set("n", "L", "<C-v>l:VBox<CR>", { buffer = true })
        vim.keymap.set("n", "H", "<C-v>h:VBox<CR>", { buffer = true })
        vim.keymap.set("v", "f", ":VBox<CR>", { buffer = true })
        vim.notify("Venn mode enabled", vim.log.levels.INFO)
      else
        vim.cmd("setlocal ve=")
        vim.b.snacks_indent_disable = false
        vim.keymap.del("n", "J", { buffer = true })
        vim.keymap.del("n", "K", { buffer = true })
        vim.keymap.del("n", "L", { buffer = true })
        vim.keymap.del("n", "H", { buffer = true })
        vim.keymap.del("v", "f", { buffer = true })
        vim.notify("Venn mode disabled", vim.log.levels.INFO)
      end
    end

    vim.keymap.set("n", "<leader>v", toggle_venn, { desc = "Venn toggle" })
  end,
}
