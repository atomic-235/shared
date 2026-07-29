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
  event = "BufReadPost",
  config = function(_, opts)
    require("csvview").setup(opts)

    local function is_csv(buf)
      local name = vim.api.nvim_buf_get_name(buf)
      return name:match("%.csv$") ~= nil or name:match("%.tsv$") ~= nil
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and is_csv(buf) and not vim.b[buf]._csvview then
        vim.b[buf]._csvview = true
        pcall(require("csvview").enable, buf)
      end
    end

    vim.api.nvim_create_autocmd("BufReadPost", {
      pattern = { "*.csv", "*.tsv" },
      callback = function(args)
        if not vim.b[args.buf]._csvview then
          vim.b[args.buf]._csvview = true
          pcall(require("csvview").enable, args.buf)
        end
      end,
      group = vim.api.nvim_create_augroup("csvview-auto", { clear = true }),
    })
  end,
  keys = {
    { "<leader>tc", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV view" },
  },
}