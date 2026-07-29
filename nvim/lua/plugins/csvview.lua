-- CSV viewer with async parsing and virtual text rendering.
-- Handles medium-large CSVs without modifying buffer content.
-- For truly massive files (>100MB), use external tools (csvlens, qsv).
return {
  "hat0uma/csvview.nvim",
  ---@module "csvview"
  ---@type CsvView.Options
  opts = {
    parser = {
      async_chunksize = 50,
      limit_max_col_count = 200,
    },
    view = {
      display_mode = "border",
    },
  },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  ft = { "csv", "tsv" },
  config = function(_, opts)
    require("csvview").setup(opts)
    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = { "*.csv", "*.tsv" },
      callback = function(args)
        pcall(require("csvview").enable, args.buf)
      end,
      group = vim.api.nvim_create_augroup("csvview-auto", { clear = true }),
    })
  end,
  keys = {
    { "<leader>tc", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
  },
}