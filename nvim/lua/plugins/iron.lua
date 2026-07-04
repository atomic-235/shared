return {
  {
    "Vigemus/iron.nvim",
    keys = {
      { "<leader>rr", desc = "Toggle REPL" },
      { "<leader>rR", desc = "Restart REPL" },
      { "<leader>rf", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
      { "<leader>rh", "<cmd>IronHide<cr>", desc = "Hide REPL" },
      { "<leader>rc", mode = { "n", "v" }, desc = "Send motion/visual" },
      { "<leader>rF", desc = "Send file" },
      { "<leader>rl", desc = "Send line" },
      { "<leader>rp", desc = "Send paragraph" },
      { "<leader>ru", desc = "Send until cursor" },
      { "<leader>rb", desc = "Send code block" },
      { "<leader>rn", desc = "Send code block and move" },
    },
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      iron.setup({
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              command = { "bash" },
            },
            python = {
              command = function()
                local cwd = vim.fn.getcwd()
                local venv = cwd .. "/.venv/bin/ipython"
                local ipython_cmd = vim.fn.filereadable(venv) == 1 and venv or "ipython"

                local pythonpath = cwd .. "/src"
                local existing = vim.env.PYTHONPATH
                if existing then
                  pythonpath = pythonpath .. ":" .. existing
                end

                return {
                  "env",
                  "PYTHONPATH=" .. pythonpath,
                  ipython_cmd,
                  "--no-autoindent",
                  "--theme=linux",
                }
              end,
              format = common.bracketed_paste_python,
              block_dividers = { "# %%", "#%%" },
            },
          },
          -- set the file type of the newly created repl to ft
          repl_filetype = function(bufnr, ft)
            return ft
          end,
          -- Send selections to the DAP repl if an nvim-dap session is running
          dap_integration = true,
          -- How the repl window will be displayed (like nvim terminal)
          repl_open_cmd = "belowright 15 split",
        },
        -- Iron doesn't set keymaps by default anymore
        keymaps = {
          toggle_repl = "<leader>rr",
          restart_repl = "<leader>rR",
          send_motion = "<leader>rc",
          visual_send = "<leader>rc",
          send_file = "<leader>rF",
          send_line = "<leader>rl",
          send_paragraph = "<leader>rp",
          send_until_cursor = "<leader>ru",
          send_code_block = "<leader>rb",
          send_code_block_and_move = "<leader>rn",
          mark_motion = "<leader>rm",
          mark_visual = "<leader>rm",
          remove_mark = "<leader>rM",
          cr = "<leader>r<cr>",
          interrupt = "<leader>r<space>",
          exit = "<leader>rq",
          clear = "<leader>rL",
        },
        -- If the highlight is on, you can change how it looks
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      })
    end,
  },
}
