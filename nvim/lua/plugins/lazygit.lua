return {
  "folke/snacks.nvim",
  opts = {
    lazygit = {
      configure = true,
      config = {
        os = { editPreset = "nvim-remote" },
      },
      win = {
        style = "lazygit",
        -- Use 0 for full-width/height (minus borders).
        -- Avoids rounding issues that 0.999 causes with centering.
        -- Use functions to compute exact dimensions that fill the
        -- screen with no extra margin (accounting for border).
        width = 0,
        height = 0,
        border = "single",
        resize = false,
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("VimResized", {
      group = vim.api.nvim_create_augroup("lazygit_resize", { clear = true }),
      callback = function()
        local target_win
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local config = vim.api.nvim_win_get_config(win)
            if vim.bo[buf].buftype == "terminal" and config.relative ~= "" then
              target_win = win
              break
            end
          end
        end
        if not target_win then
          return
        end
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(target_win) then
            vim.api.nvim_win_close(target_win, true)
          end
          vim.defer_fn(function()
            Snacks.lazygit()
          end, 50)
        end)
      end,
    })
  end,
}
