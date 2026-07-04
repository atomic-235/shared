-- DAP (Debug Adapter Protocol) configuration
-- debugpy is provided by pkgs.debugpy (NixOS system package), not Mason.
-- The `debugpy-adapter` binary ships with pkgs.debugpy and is on $PATH.
-- On NixOS with uv2nix there is no .venv or VIRTUAL_ENV, so resolve_python
-- must be overridden to use UV_PYTHON from the shell environment instead.
return {
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local dap_python = require("dap-python")
      dap_python.setup("debugpy-adapter")
      dap_python.resolve_python = function()
        return os.getenv("UV_PYTHON")
      end
    end,
  },

  -- Replace LazyVim's dap-ui with dap-view (single full-width window)
  { "rcarriga/nvim-dap-ui", enabled = false },
  { "theHamsta/nvim-dap-virtual-text", enabled = false },

  {
    "igorlfs/nvim-dap-view",
    lazy = false,
    version = "1.*",
    opts = {
      winbar = {
        show = true,
        sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
        default_section = "watches",
      },
      windows = {
        size = 0.25,
        position = "below",
        terminal = {
          size = 0.5,
          position = "left",
          hide = {},
        },
      },
      auto_toggle = true,
    },
    keys = {
      { "<leader>du", function() require("dap-view").toggle() end, desc = "Dap View Toggle" },
      { "<leader>dv", function() require("dap-view").open() end, desc = "Dap View Open" },
      { "<leader>de", function() require("dap-view").add_expr() end, desc = "Dap Watch Expr", mode = { "n", "x" } },
    },
  },

  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dw",
        function()
          local dap = require("dap")
          local widgets = require("dap.ui.widgets")
          local expr = vim.fn.expand("<cexpr>")
          if expr == "" then return end
          local session = dap.session()
          if not session then
            widgets.hover(expr)
            return
          end
          local frame_id = session.current_frame and session.current_frame.id or nil
          local function show_df_float(text)
            text = text:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub("^'", ""):gsub("'$", "")
            local lines = vim.split(text, "\n", { plain = true })
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].bufhidden = "wipe"
            vim.bo[buf].filetype = "text"
            local max_width = 0
            for _, l in ipairs(lines) do
              local w = vim.fn.strdisplaywidth(l)
              if w > max_width then max_width = w end
            end
            local width = math.min(vim.o.columns - 4, max_width + 4)
            local height = math.min(vim.o.lines - 4, #lines + 2)
            local win = vim.api.nvim_open_win(buf, true, {
              relative = "editor",
              row = math.max(0, math.floor((vim.o.lines - height) / 2)),
              col = math.max(0, math.floor((vim.o.columns - width) / 2)),
              width = width,
              height = height,
              border = "rounded",
              style = "minimal",
              title = expr,
              title_pos = "center",
            })
            vim.wo[win].wrap = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
            vim.api.nvim_win_set_cursor(win, { 1, 0 })
          end
          local eval_opts = { expression = "type(" .. expr .. ").__name__", context = "hover", frameId = frame_id }
          session:evaluate(eval_opts, function(err, resp)
            local typename = not err and resp and vim.trim(resp.result:match("'([^']+)'") or resp.result or "") or ""
            if typename:match("DataFrame") or typename:match("Series") then
              local df_opts = { expression = "str(" .. expr .. ")", context = "clipboard", frameId = frame_id }
              session:evaluate(df_opts, function(e2, r2)
                if e2 or not r2 or not r2.result then
                  widgets.hover(expr)
                  return
                end
                show_df_float(r2.result)
              end)
            else
              widgets.hover(expr)
            end
          end)
        end,
        desc = "Widgets",
      },
    },
  },
}
